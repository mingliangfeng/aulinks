# encoding: utf-8
ActiveAdmin.register LinksFile do
  form :partial => "form"
  
  member_action :import_urls, :method => :put do
    links_file = LinksFile.find(params[:id])
    links_file.import_urls!
    redirect_to admin_root_url, :notice => "All links in #{links_file.attachment_file_name} have been imported into database!"
  end
  

end
