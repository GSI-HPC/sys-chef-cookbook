class Chef::Mixin::Template::TemplateContext
  def template_header(comment = '#')
    <<-HEADER.gsub(/^ */, "#{comment} ")
    DO NOT CHANGE THIS FILE MANUALLY!

    This file is managed by chef.
    Check #{@cookbook_name}::#{@recipe_name} line #{@recipe_line} for details.
    HEADER
  end
end
