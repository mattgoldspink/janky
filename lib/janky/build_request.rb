module Janky
  class BuildRequest
    def self.handle(repo_uri, branch_name, commit, compare, room_id)
      repos = Repository.find_all_by_uri(repo_uri)
      repos.each do |repo|
        begin
          new(repo, branch_name, commit, compare, room_id).handle
        rescue Janky::Error => boom
          Exception.report(boom, :repo => repo.name)
        end
      end

      repos.size
    end

    def initialize(repo, branch_name, commit, compare, room_id)
      @repo        = repo
      @branch_name = branch_name
      @commit      = commit
      @compare     = compare
      @room_id     = room_id
    end

    def handle
      current_build = commit.last_build
      build = branch.build_for(commit, @room_id, @compare)

      if !current_build || (current_build && current_build.red?)
        if @repo.enabled?
          build.run
        end
      end
    end

    def branch
      @repo.branch_for(@branch_name)
    end

    def commit
      @repo.commit_for(
        :sha1         => @commit.sha1,
        :url          => @commit.url,
        :message      => @commit.message,
        :author       => @commit.author,
        :committed_at => @commit.committed_at
      )
    end
  end
end
