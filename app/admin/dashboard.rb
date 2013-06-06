# encoding: utf-8
ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }
  
  page_action :gen_links, :method => :put do
    gen_top_links
    gen_hot_links
    gen_new_links
    gen_utility_links
    gen_events_links
    gen_category_links
    gen_category_boxes
    
    gen_public_homepage
    gen_public_categories
    redirect_to admin_root_url, :notice => "All links have been generated based on current data in database!"
  end

  action_item do
    link_to "Generate All Links", admin_dashboard_gen_links_path, :method => :put
  end
  
  controller do
    def gen_top_links
      group = 0
      i = 0
      top_links = []
      Category.find_by_hid(1).links.order('show_order asc').each_with_index do |link, i|
        top_links << '<ul>' if i % 6 == 0
        top_links << gen_link_html(link, 1, 2)
        if i % 6 == 5
          top_links << '</ul>'
          group = group + 1
          top_links << '<ul class="top-seperator"><li></li></ul>' if group == 3
        end
      end

      write_to("top-links.html", top_links.join)
    end

    def gen_hot_links
      hot_links = []
      index = 0
      Link.hot_links.limit(8).each do |link|
        category = link.category_relations.first.category
        hot_links << "<ul>"
        hot_links << "<li class='first'>#{gen_category_anchor(category)}</li>"
        hot_links << "<li class='last'>#{gen_link_anchor(link, category.hid, 2)}</li>"
        hot_links << "</ul>"
        index = index + 1
      end

      write_to("hot-links.html", hot_links.join)
    end
    
    def gen_new_links
      category = Category.find_by_hid(3)
      gen_common_links(category, 18, 'new-links.html')
    end
    
    def gen_utility_links
      category = Category.find_by_hid(4)
      gen_common_links(category, 16, 'utility-links.html')
    end
    
    def gen_common_links(category, limit, file_name)
      common_links = []
      index = 0
      category.sorted_links.limit(limit).each_with_index do |link, i|
        common_links << '<ul>' if i % 2 == 0        
        common_links << "<li class='#{i % 2 == 0 ? "first" : "last"}'>#{gen_link_anchor(link, category.hid, 2)}</li>"
        common_links << '</ul>' unless i % 2 == 0
      end
      write_to(file_name, common_links.join)
    end
    
    def gen_events_links
      events_links = []
      category = Category.find_by_hid(5)
      category.sorted_links.limit(10).each_with_index do |link, i|
        events_links << "<ul>"
        events_links << "<li class='first'>#{gen_link_anchor(link, category.hid, 2)}</li>"
        events_links << "<li class='last' title='#{link.city_desc}'>#{link.info}</li>"
        events_links << "</ul>"
      end
      
      write_to('events-links.html', events_links.join)
    end
    
    def gen_category_links
      category_links = ['<ul style="height:0;"><li></li></ul>']
      index = 0
      category_ul = ['<ul class="ss-ul">']
      category_nav = ['<ul id="sitemap"><li class="title">[ <h2>Sitemap</h2> ]</li>']
      Category::TOP_CATEGORIES.each_with_index do |hid, i|
        category = Category.find_by_hid(hid)
        category_links << gen_category_link(category)
        category_ul << "<li>#{gen_category_anchor(category)}</li>"
        category_nav << "<li>#{gen_category_anchor(category)}</li>"
        category_links << "<ul class='main-seperator'><li></li></ul>" if i == 5 or i == 10 or i == 15 or i == 20
      end

      category_ul << '</ul>'
      category_nav << '</ul>'
      category_links << '<ul style="height:0;"><li></li></ul>'

      write_to('category-links.html', category_links.join)
      write_to('category-ul.html', category_ul.join)
      write_to('category-nav.html', category_nav.join)
    end
    
    def gen_category_boxes
      Category::TOP_CATEGORIES.each do |hid|
        category = Category.find_by_hid(hid)
        category_links = []
        category_ul = ["<ul class='ss-ul'><li>#{category.name} websites</li>"]
        category.subordinateli_categories.each do |sub_category|
          category_links << gen_category_box(sub_category)
          category_ul << "<li>#{sub_category.name} websites</li>"
        end
            
        category_ul << '</ul>'
        
        write_to("category-#{category.name.downcase}.html", category_links.join)
        write_to("category-ul-#{category.name.downcase}.html", category_ul.join)

        related_cate = []
        category.related_categories.each do |related_category|
          related_cate << "<div><a href='/' title='#{Category::HOME_TITLE}'>Home</a> <span class='nav-arrow'>»</span> #{gen_category_anchor(related_category)}</div>"
        end
        write_to("related-category-#{category.name.downcase}.html", related_cate.join)
      end
    end
    
    def gen_public_homepage
      homepage = render_to_string(partial: "application/index", layout: "layouts/application")
      write_to_public("index.html", homepage)
    end
    
    def gen_public_categories
      Category::TOP_CATEGORIES.each do |hid|
        category = Category.find_by_hid(hid)
        category_html = render_to_string(partial: "application/category", layout: "layouts/application",
                        locals: {category_object: category})
        write_to_public("#{category.encode_name}.html", category_html)
      end
    end
    
    def gen_category_link(category)
      category_link = ['<ul>']
      category_link << "<li class='title'>[ #{gen_category_anchor(category)} ]</li>"
      category.sorted_links.limit(7).each do |link|
        category_link << gen_link_html(link, 1)
      end
      category_link << "<li class='last'>#{view_context.link_to "more»", category.encode_url, title: category.title}</li></ul>"
      category_link.join
    end
    
    def gen_category_box(category)
      all_links = category.sorted_links.reject {|link| link.is_sub? }
      cate_links = ["<div class='one-box'><div class='box-title'><h2>#{category.name} (#{all_links.count})</h2></div><div class='box-content'><div class='cate2'>"]
      all_links.each_with_index do |link, i|
        cate_links << '<ul class="section-seperator"><li></li></ul>' if i > 0 and i % 10 == 0
        cate_links << "<ul class='#{"img-link" if category.image_category?}'>" if i % 5 == 0
        if category.image_category?
          url = interal_path(link, category.hid)
          anchor = view_context.link_to(url, dd: "#{link.id}-#{category.hid}", class: "link1 l#{link.id} img-link", rel: "nofollow") {
            view_context.content_tag(:span, "", id: link.info)
          }
          cate_links << "<li>#{anchor}#{tooltip(link, category.hid)}</li>"
        else
          cate_links << gen_link_html(link, category.hid)
        end
        
        cate_links << '</ul>' if i % 5 == 4
      end
      cate_links << '</ul>' if all_links.count % 5 != 0
      cate_links << '</div><div style="clear: both;"></div></div></div>'
      cate_links.join
    end
    
    def tooltip(link, hid)
      display = link.title or abstract_url(link.url)
      tooltip_html = ['<div class="tip-holder"><div class="tooltip">']
      tooltip_html << display << "<br/>" << link.url
      sub_links_html = link.sub_links.inject([]) {|r, l| r << gen_link_anchor(l, hid, 1) }
      unless sub_links_html.blank?
        tooltip_html << "<br/>" << sub_links_html.join(" ")
      end
      tooltip_html << '<span class="arrow-top"></span></div></div>'
      tooltip_html.join
    end

    def gen_link_html(link, hid, type=1)
      favicon = ''
      "<li>#{favicon}#{gen_link_anchor(link, hid, type)}</li>"
    end

    def gen_link_anchor(link, hid, type)
      display = link.title || abstract_url(link.url)
      url = link.url
      url = interal_path(link, hid) unless type == 2
      view_context.link_to link.name, url, dd: "#{link.id}-#{hid}", class: "link#{type} l#{link.id}", rel: "nofollow", title: display
    end
    
    def interal_path(link, hid)
      "/url/#{link.id}-#{hid}-#{link.name.gsub(' ', '-')}"
    end

    def gen_category_anchor(category)
      view_context.link_to category.name, category.encode_url, title: category.title
    end

    def get_full_file_path(*paths, file_name)
      Rails.root.join(*paths, file_name)
    end

    def write_to(file_name, content)
      write_to_file get_full_file_path('app', 'views', 'snippets', "_#{file_name}"), content
    end
    
    def write_to_public(file_name, content)
      write_to_file get_full_file_path('public', file_name), content
    end
    
    def write_to_file(file_path, content)
      File.open(file_path, "w:utf-8") {|f| f.write content }
    end
  end

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    # div :class => "blank_slate_container", :id => "dashboard_default_message" do
    #   span :class => "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
    
    #@links_files = LinksFile.all
    #render "index"
    
    columns do
      column do
        panel "Recent Links Files" do
          table_for LinksFile.order('created_at desc') do
            column "File Name" do |links_file|
              link_to(links_file.attachment_file_name, admin_links_file_path(links_file))
            end
            column :created_at            
            column :applied_at            
            column "Import" do |links_file|
              link_to("Import Urls", import_urls_admin_links_file_path(links_file), method: :put)
            end
          end
        end
      end
    end
  end # content
end
