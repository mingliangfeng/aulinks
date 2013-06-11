# encoding: utf-8
require 'date'

class LinksFile < ActiveRecord::Base
  attr_accessible :applied_at, :attachment
  
  has_attached_file :attachment
  validates :attachment, :attachment_presence => true
  
  def import_urls!
    delete_relations
    init_urls
    build_links
    
    self.applied_at = DateTime.now
    self.save!
  end
  
private
  def delete_relations
    LinkRelation.delete_all
    CategoryRelation.delete_all
    CategoryLink.delete_all
    Category.delete_all
  end
  
  def init_urls
    @all_urls = {}
    Link.find_each do |link|
      url = abstract_url(link.url)
      if @all_urls.has_key?(url)
        logger.warn "duplicated url: #{url} -> #{link.url}"
      else
        @all_urls[url] = link
      end
    end
  end
  
  def safe_strip(str)
    str && str.strip
  end
  
  def build_links
    cateId0 = 0
    order0 = 0
    cateorder0 = 0
    cateId1 = 0
    order1 = 0
    preLinkId = nil
    sublinkOrder = 1
    File.foreach(attachment.path) do |line|
      next if line.blank?
      words = line.split("\t")
      unless words[0].blank?
        category = Category.create(name: words[0].strip, is_top: 1, hid: safe_strip(words[1]))
        cateId0 = category.id
        order0 = 0
        cateorder0 = 0
      end
    
      unless words[2].blank?
        category = Category.create(name: words[2].strip, is_top: 0, hid: safe_strip(words[3]))
        cateId1 = category.id
        order1 = 0
        cateorder0 = cateorder0 + 1
        CategoryRelation.create(parent_id: cateId0, sub_id: cateId1, show_order: cateorder0)
      end
      
      unless words[4].blank?
        url = abstract_url(words[6])
        attributes = { name: words[4].strip, title: safe_strip(words[5]), url: format_url(url), favicon: safe_strip(words[7]), info: safe_strip(words[10]) }
        if @all_urls.has_key?(url)
          link = @all_urls[url]
          attributes[:info] = "^" if link.info == "^"
          link.update_attributes(attributes)
        else
          link = Link.create(attributes)  
        end        
        linkId = link.id
        order1 = order1 + 1
        CategoryLink.create(category_id: cateId1, link_id: linkId, show_order: order1)
        if safe_strip(words[8]) == '1'
          order0 = order0 + 1
          CategoryLink.create(category_id: cateId0, link_id: linkId, show_order: order0)
        end
        if safe_strip(words[11]) == '1'
          CategoryLink.create(category_id: cateId0, link_id: linkId, show_order: 0, recommend: 1) # recommended links for category have not order
        end
        if safe_strip(words[10]) == '^'
          LinkRelation.create(parent_id: preLinkId, sub_id: linkId, show_order: sublinkOrder)
          sublinkOrder = sublinkOrder + 1
        else
          sublinkOrder = 1
          preLinkId = linkId
        end
      end
      
    end
    
    File.foreach(attachment.path) do |line|
      next if line.blank?
      words = line.split("\t")
      unless words[0].blank? or words[9].blank?
        category = Category.find_by_hid safe_strip(words[1])
        cateId0 = category.id
        relatedHids = words[9].strip.split(';')
        rt_index = 1
        relatedHids.each do |rhid|
          rhid.strip!
          unless rhid.empty?
            sub_category = Category.find_by_hid(rhid)
            CategoryRelation.create(parent_id: cateId0, sub_id: sub_category.id, show_order: rt_index, related: 1)
            rt_index = rt_index + 1
          end
        end     
      end
    end
  end
  
  def abstract_url(url)
    return nil if url.blank?
    url.strip!
    url = delete_if_start_with(url, "https://")
    url = delete_if_start_with(url, "http://")
    url = delete_if_start_with(url, "www.")
  end
  
  def format_url(url)
    return nil if url.blank?
    url.strip!
    url = 'http://' + url unless url.start_with?('http://') or url.start_with?('https://')
    url = url[0...-1] if url.end_with?('.com.au/') or url.end_with?('.com/') or url.end_with?('.gov.au/') or url.end_with?('.org.au/')
    url
  end
  
  def delete_if_start_with(str, prefix)
    str.start_with?(prefix) ? str[prefix.length..-1] : str
  end
  
end
