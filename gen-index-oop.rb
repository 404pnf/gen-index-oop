# ## 使用方法
#
#     ruby script.rb inputdir

# ## 脚本目的
#
# 递归地生成输入文件夹中所有目录的index.html文件。该文件有其所处目录的所有文件名和链接。
#
# 相比web server默认渲染的文件列表，本脚可生成自定义样式的文件列表。
#
# ----

# ## 帮助函数
#
# 输入一个目录
#
# 返回该目录下所有的目录，递归
#
# 返回的是一个数组
#
# ----
module GetDir
  # 把输入目录添加到结果数组中
  def get_dir(path)
    Dir["#{path}/**/*"].select { |e| File.directory? e} + [path]
  end

  module_function :get_dir
end

# ## 用类封装
#
# 输入是一个目录。
#
# 输出是该目录下所有文件列表，不包括以英文点开头的文件。
#
# 输出是数组
#
# ----
class IndexHtml

  # 我还不知道这种情况下如何使用erb
  require 'cgi'
  require 'erubis'
  #require 'erb'

  attr_accessor :path, :tpl, :domain

  def initialize(path, tpl = 'index.eruby', domain = '/')
    @path = path
    @tpl = tpl
    @domain = domain
    @context = self.context
  end

  def write
    self.del_index
    eruby = Erubis::Eruby.new(File.read(@tpl))
    index_html =  eruby.evaluate(@context)
    #index_html = ERB.new(File.read(@tpl)).result binding
    out = File.join(@path, 'index.html')
    p "generating #{out}"
    File.write(out, index_html)
  end

  def del_index
    Dir["#{@path}/**/index.html"].each { |e| File.delete e; p "deleting #{e}" }
  end

  protected

  def context
    {
      :title => self.title,
      :links   => self.links,
      :domain => self.domain,
    }
  end

  def files
    Dir["#{@path}/*"].map { |e| File.basename e} # no unix dot files
  end

  def title
    @path.split('/').last
  end

  def links
    self.files.map { |e| [e, CGI.escape(e)]}.sort
  end

end

# ## 干活
if __FILE__ == $PROGRAM_NAME
  inputdir = ARGV[0] || '~/tmp/'
  p "inputdir is #{inputdir}"
  GetDir.get_dir(inputdir).each { |e| IndexHtml.new(e).write }
end
