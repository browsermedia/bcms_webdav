Rails.application.routes.draw do

  mount BcmsWebdav::Engine => "/bcms_webdav"
	mount_browsercms
end
