class Chef::Mixin::Template::TemplateContext
  def chef_product_name
    begin
      ChefUtils::Dist::Infra::SHORT
    rescue NameError
      'chef' # fallback if chef too old
    end
  end

  def template_header(comment = '#')
    <<-HEADER.gsub(/^ */, "#{comment} ")
    DO NOT CHANGE THIS FILE MANUALLY!

    This file is managed by #{chef_product_name}.
    Created by #{@cookbook_name}::#{@recipe_name} (line #{@recipe_line}) from template #{@template_name}.
    HEADER
  end
end
