
# module GitCleaner
#   class Error < StandardError; end
#
#
# end

class Runner
  def initialize(argv)
    @work_dir = argv[1]
  end

  def run
    Dir.chdir(@work_dir)

    message(35,"-> 请确认本地所有feature分支都已合并完成！")
    message(35,"-> 请确认本地所有tag都删除完成!")

    message(33,"-> 同步仓库代码...")
    command = "git fetch --quiet && git pull --quiet"
    m = `#{command}`.lines.to_s
    if $?.exitstatus != 0
      message(31,"-> 同步仓库代码失败！ERROR：#{m}")
      return
    end
    message(32,"-> 仓库代码同步完成")

    message(33,"-> 正在查找大文件...")
    command = "git rev-list --objects --all | grep \"$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3 | awk '{print$1}')\""
    file_paths = `#{command}`.lines.map { |f| f.split(' ')[1]  }
    if file_paths.empty?
      message(32,"-> 没有找到需要清理的大文件！command：#{command}")
      return
    end

    file_paths.each { |path|
      message(33,"-> 正在清理：#{path} ...")
      `git filter-repo --invert-paths --force --path "#{path}"`
      message(31,"-> 清理失败！file：#{path}") if $?.exitstatus != 0
    }
    message(32,"-> 清理完成！本次共清理#{file_paths.length}个大文件！")

    puts "-> 正在清理Git垃圾..."
    message(33,"-> 正在清理Git垃圾...")
    `rm -rf .git/refs/original/`
    `git reflog expire --expire=now --all`
    `git gc --prune=now --quiet`
    message(32,"-> Git垃圾清理完成！")
    message(32,"-> 下一步检查工程无误后可用 git push -u origin develop --force 命令强制覆盖远程代码。")
  end

  def message(code, str)
    puts "\e[#{code}m#{str}\e[0m"
  end

end
