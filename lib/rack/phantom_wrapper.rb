module PhantomWrapper

  class PngFile
    def initialize(file)
      @png_file = file
    end

    def open
      @png_file.open
      @png_file.rewind
    end

    def each(&blk)
      @png_file.each(&blk)
    ensure
      @png_file.close
    end

    def size
      puts "Size is #{@png_file.size}"
      @png_file.size
    end
  end

  class Base
    PROGRAM = 'phantomjs'
    RASTERIZE_JS = File.join(File.dirname(__FILE__),'rasterize.js')

    def document(html,url_base)
      """
      <!DOCTYPE html>
      <html>
        <head>
          <meta content='text/html;charset=utf-8' http-equiv='Content-Type'>
          <title>SVG CONVERT</title>
          <link href='#{url_base}/embeddable.css' rel='stylesheet' type='text/css'>
          <link href='#{url_base}/interactives.css' rel='stylesheet' type='text/css'>
          <link href='http://fonts.googleapis.com/css?family=Lato:300italic,700italic,300,400,400italic,700' rel='stylesheet' type='text/css'>
        </head>
        <body>
          <!--
            <div id='responsive-content'>
              <div id='interactive-container' tabindex='0'>
              </div>
            </div>
          -->
          <div id='dynamic_content'>
            #{html}
          </div>
        </body>
      </html>
      """
    end

    def initialize
      @png_file_cache = {}
    end


    def convert(html,base_url)
      html_content = document(html,base_url)
      signature = Digest::SHA1.hexdigest(html_content)[0..10]
      return signature if @png_file_cache[signature]

      infile = Tempfile.new(['phantom_page','.html'])
      infile_name = infile.path

      outfile = Tempfile.new(['phantom_render','.png'])
      outfile_name = outfile.path

      begin
        infile.write(html_content)
        infile.rewind
        %x[#{PROGRAM} #{RASTERIZE_JS} #{infile_name} #{outfile_name}]
        @png_file_cache[signature] = PngFile.new(outfile)
      ensure
        infile.close
        infile.unlink
      end
      return signature
    end

    def get_png_file(sha)
      file = @png_file_cache[sha]
      file.open
      return file
    end

  end
end
