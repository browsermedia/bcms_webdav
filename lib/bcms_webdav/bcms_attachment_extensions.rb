Attachment.class_eval do

  # Exist to ensure compliance with Resource API for WebDAV (like Section and Pages).
  def path
    file_path
  end
end