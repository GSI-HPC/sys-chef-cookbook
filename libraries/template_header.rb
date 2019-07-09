class Chef::Mixin::Template::TemplateContext
  def template_header(comment = '#')
    <<-HEADER.gsub(/^ */, "#{comment} ")
    DO NOT CHANGE THIS FILE MANUALLY!

    This file is managed by chef.
    Created by #{@cookbook_name}::#{@recipe_name} (line #{@recipe_line}) from template #{@template_name}.
    HEADER
  end
end
