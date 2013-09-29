require 'pp'
# 输入一个目录
# 返回该目录下所有的目录，递归
# 返回的是一个数组
module GetDir
	def get_dir(path)
		Dir["#{path}/**/*"].select { |e| File.directory? e}
	end

	module_function :get_dir
end

# 输入是一个目录
# 输出是该目录下所有文件列表，不包括以英文点开头的文件
# 输出是数组
class IndexHtml

	#require 'fileutils'
	require 'cgi'
	#require 'find'
	require 'erubis'

	attr_accessor :path, :tpl, :domain

	def initialize(path, tpl = 'index.eruby', domain = '/')
		@path = path
		@tpl = tpl
		@domain = domain
	end

	def files
		@files = Dir["#{@path}/*"].map { |e| File.basename e}
	end

	def title
		@path.split('/').last
	end

	def links
		@links = self.files.map { |e| [e, CGI.escape(e)]}.sort
	end

	def context
		@context = {
			:title => self.title,
			:links	 => self.links,
			:domain => self.domain,
		}
	end

	def write
		Dir["#{path}/**/index.html"].each { |e| File.delete e }
		eruby = Erubis::Eruby.new(File.read(@tpl))
    index_html =  eruby.evaluate(self.context)
		out = File.join(@path, 'index.html')
		File.write(out, index_html)
	end

end

GetDir.get_dir('.').each { |e|
	IndexHtml.new(e).write
}