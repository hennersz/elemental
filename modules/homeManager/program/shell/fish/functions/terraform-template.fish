function terraform-template
  if not set -q TERRAFORM_TEMPLATE_DIR
    echo "template directory not set"
    exit 1
  end

  cp -r $TERRAFORM_TEMPLATE_DIR/$argv[1]/* $argv[2]
end 