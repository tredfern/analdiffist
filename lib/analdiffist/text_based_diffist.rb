
module AnalDiffist
  class TextBasedDiffist
    def initialize
      @files = []
    end
    def report_results
      diff @files[0], @files[1]
    end
    
    def do_analytics ref_name
      dest_filename = get_file_name ref_name
      puts 'writing analytics to ' + dest_filename
      
      reek_result = `reek -q #{@targets}`
      flog_result = `flog -g #{@targets}`
      File.open(dest_filename, 'w') do |f|
        f.write"--- Analytics for #{ref_name} ---\n\n"

        f.write"\n\n--- FLOG ---\n\n"
        f.write clean_up_flog(flog_result)

        f.write"\n\n--- REEK ---\n\n"
        f.write reek_result
      end

      @files << dest_filename
    end

    def get_file_name ref_name
      File.join(Dir.tmpdir, "#{ref_name.gsub('/', '_')}-analytics.txt")
    end

    def clean_up_flog(flog_result)
      flog_result.gsub(/:[0-9]+$/, '')
    end
    def diff f1, f2
      git diff --color=always -U0 -- '#{f1}' '#{f2}'`
    end
  end
end
