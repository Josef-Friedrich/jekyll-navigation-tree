# For debugging purposes use: pp variable
#require("pp")
#require("awesome_print")

# based on https://gist.github.com/brandonmwest/3536551

module Jekyll
  # Add accessor for directory
  class Page
    attr_reader :dir
  end

  class NavigationTree < Liquid::Tag

    def initialize(tag_name, path, tokens)
      super
      @path = path
    end

    def render(context)
      site = context.registers[:site]

      @page_url = context.environments.first["page"]["url"]
      # @page_url: "/tech/"

      @dirs = {}
      tree = {}

      site.pages.each do |page|
        if ! page.data.has_key? "nav_tree" || page.data["nav_tree"] == true
          #  page: #<Jekyll:Page @name="Motorola-Moto-E-2nd-Gen-XT1524-4G-LTE.md">
          path = page.url
          # path: /tech/hardware/Motorola-Moto-E-2nd-Gen-XT1524-4G-LTE.html
          path = path.index('/') == 0 ? path[1..-1] : path

          # page.data:

          # {
          #        "layout" => "page",
          #         "title" => "About",
          #     "permalink" => "/about/"
          # }
          @dirs[path] = page.data
        end
      end

      # @dirs:

      # {
      #   "tech/hardware/Motorola-Moto-E-2nd-Gen-XT1524-4G-LTE.html"=>{
      #     "title"=>"Motorola Moto E 2nd Gen XT1524 4G LTE"
      #   },
      #  "about/ "=> {
      #    "layout"=>"page",
      #    "title"=>"About",
      #    "permalink"=>"/about/"
      #   },
      #   "tech/commands/adb.html"=>{
      #     "title"=>"adb (Android Debug Bridge)"
      #   },
      #   "tech/websites/lrz-seite-2003/"=>{
      #     "title"=>"LRZ-Seite (2003)"
      #   },
      # }

      @dirs.each do |path, data|
        current = tree
        path.split("/").inject("") do |sub_path, dir|
          sub_path = File.join(sub_path, dir)

          current[sub_path] ||= {}
          current = current[sub_path]
          sub_path
        end
      end

      puts "Generating navigation tree for: #{@page_url}"

      # tree:
      # {"/tech"=>
      #   {"/tech/hardware"=>
      #     {"/tech/hardware/Motorola-Moto-E-2nd-Gen-XT1524-4G-LTE.html"=>{},
      #      "/tech/hardware/banana-pi-pro.html"=>{},
      #      "/tech/hardware/brother-hl-5350dn.html"=>{},
      if @path == nil || @path == ""
        base_path = @page_url.chomp('/')
      else
        base_path = @path.strip.chomp('/')
      end

      if base_path == ""
        sub_tree = tree
      else
        if base_path.index('/') != 0
          base_path = '/' + base_path
        end
        sub_tree = tree[base_path]
      end

      files_first_traverse("", sub_tree)
    end

    def files_first_traverse(prefix, node = {})
      output = ""
      output += "#{prefix}<ul>"
      node_list = node.sort

      # node_list:

      # [["/about", {}],
      #  ["/assets", {"/assets/main.css"=>{}}],
      #  ["/feed.xml", {}],
      #  ["/imprint", {}],
      #  ["/mixing",
      #   {"/mixing/defaults.html"=>{},
      #    "/mixing/shure-beta-58a.html"=>{},
      #    "/mixing/shure-ulx.html"=>{},
      #    "/mixing/t-bone-free-solo-pt-823-mhz.html"=>{}}],
      #  ["/rezepte",
      #   {"/rezepte/fleisch"=>
      #     {"/rezepte/fleisch/amerikanisches-rindersteak.html"=>{},
      #      "/rezepte/fleisch/chili-con-carne.html"=>{},
      #      "/rezepte/fleisch/fleischpfanzerl.html"=>{},

      node_list.each do |base, subtree|
          # base: "/about"
          name = base[1..-1]
          # name: "about"
          if name.index('.html')
            name = @dirs[name]["title"] || name
          # e. g.: "tech/websites/lrz/index.html" => is "tech/websites/lrz/"
          # in @dirs hash.
          elsif @dirs.has_key? name + "/"
            name = @dirs[name + "/"]["title"] || name
          end

          output += "#{prefix}	 <li><a href=\"#{base}\">#{name}</a></li>" if subtree.empty?
      end

      node_list.each do |base, subtree|
        next if subtree.empty?
          name = base[1..-1]
          # name: "tech/commands"
          if @dirs.has_key? name + '/'
            href = base
            name = @dirs[name + '/']['title'] || name
          elsif name.index('/')
            name = name[name.rindex('/')+1..-1] || name
          end

          if href
            name_link = "<a href=\"#{base}\">#{name}</a>"
          else
            name_link = "<div class=\"subtree-name\">#{name}</div>"
          end

          output += "#{prefix}	<li>#{name_link}"
          output += files_first_traverse(prefix + '	 ', subtree)
          output+= "</li>"

        end

        output += "#{prefix} </ul>"
        output
      end
    end
end

Liquid::Template.register_tag("navigation_tree", Jekyll::NavigationTree)
