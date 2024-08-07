require "language/node"

class GitlabCiLocal < Formula
  desc "Run gitlab pipelines locally as shell executor or docker executor"
  homepage "https://github.com/firecow/gitlab-ci-local"
  url "https://registry.npmjs.org/gitlab-ci-local/-/gitlab-ci-local-4.52.1.tgz"
  sha256 "68677db10d5394a524ddf2c8b1d504b0a0655da2615f44870b5be70649affd3e"
  license "MIT"
  head "https://github.com/firecow/gitlab-ci-local.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "f0c3e9e66fc1923f04c024e7b9fcb182a3d45e7db04e9f63445c8992f5126daf"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f0c3e9e66fc1923f04c024e7b9fcb182a3d45e7db04e9f63445c8992f5126daf"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f0c3e9e66fc1923f04c024e7b9fcb182a3d45e7db04e9f63445c8992f5126daf"
    sha256 cellar: :any_skip_relocation, sonoma:         "fa741360f19e51b3d44fe21c6e0d55d0a7980215b25c493daf2fdb96c0740779"
    sha256 cellar: :any_skip_relocation, ventura:        "fa741360f19e51b3d44fe21c6e0d55d0a7980215b25c493daf2fdb96c0740779"
    sha256 cellar: :any_skip_relocation, monterey:       "fa741360f19e51b3d44fe21c6e0d55d0a7980215b25c493daf2fdb96c0740779"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "703dde5cabe8a4b081318c0ff30fea5d0247873a9ee4218d978c8cf37373dd79"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/".gitlab-ci.yml").write <<~YML
      ---
      stages:
        - build
        - tag
      variables:
        HELLO: world
      build:
        stage: build
        needs: []
        tags:
          - shared-docker
        script:
          - echo "HELLO"
      tag-docker-image:
        stage: tag
        needs: [ build ]
        tags:
          - shared-docker
        script:
          - echo $HELLO
    YML

    system "git", "init"
    system "git", "add", ".gitlab-ci.yml"
    system "git", "commit", "-m", "'some message'"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"
    rm ".git/config"

    (testpath/".git/config").write <<~EOS
      [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
      [remote "origin"]
        url = git@github.com:firecow/gitlab-ci-local.git
        fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
        remote = origin
        merge = refs/heads/master
    EOS

    assert_match(/name\s*?description\s*?stage\s*?when\s*?allow_failure\s*?needs\n/,
        shell_output("#{bin}/gitlab-ci-local --list"))
  end
end
