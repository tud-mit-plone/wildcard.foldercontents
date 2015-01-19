# wildcard.foldercontents

A better folder contents view for plone.

## Features

 * Multi-file upload with Drag&Drop from the desktop
 * Improved manual reordering
 * Per-document menu with shortcuts to often-needed actions
 * Shift-click selection
 * Static folder sorting

## Architecture

At its heart, the add-on overrides Plone's browser view for the folder contents. The original view lives in ` plone.app.content.browser.foldercontents.FolderContentsView`. It gets replaced by a more modern version for which the add-on includes some CSS and JavaScript libaries. Namely, they are [*Bootstrap*][bootstrap] for theming and drop-down menus and [*jQuery File Upload*][jq-upload] for the integrated file uploader. The latter pulls a bunch of dependencies, including [*jQuery UI*][jq-ui]. The sortable table implementation also requires *jQuery UI*.

[bootstrap]: http://getbootstrap.com/
[jq-upload]: https://blueimp.github.io/jQuery-File-Upload/
[jq-ui]: https://jqueryui.com/

### Profiles

The default profile only defines a browser layer for the the dependencies of the add-on. The test profile is still empty.

### Browser Views

All views are implemented in `wildcard.foldercontents.views`. The actual folder view is split into multiple views. Additionally, there are the views handling the actions of the folder view.

 The templates for the views are stored in the same folder.

| *View*                  | *Template*          | *Description*                                                                   |
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| NewFolderContentsView   | folder_contents.pt  | Inherits from `plone.app.browser.foldercontents.FolderContentsView`. Provides   |
|                         |                     | the environment for the folder view. For that, the necessary CSS and JavaScript |
|                         |                     | resources are added to the relevant slots of the master template. The actual    |
|                         |                     | folder view is put into the slot `content_core`. For this the view uses an      |
|                         |                     | instance of `NewFolderContentsTable`. After that, the markup for the forms for  |
|                         |                     | the upload and sort function follows.                                           |
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| NewFolderContentsTable  | -                   | Inherits from `plone.app.browser.foldercontents.FolderContentsTable`. It        |
|                         |                     | collects the data for the folder listing. For this it reuses the methods        |
|                         |                     | `folderitems()` and `buttons()` from `FolderContentsTable`. The view has no     |
|                         |                     | dedicted template. Instead it contains in the attribute `table` an instance of  |
|                         |                     | `plone.app.content.browser.tableview.Table, a view for displaying a sortable    |
|                         |                     | HTML table. Here, an instance of `NewTable` is used.                            |
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| NewTable                | table.pt            | Inherits from `plone.app.browser.tableview.Table`. For the most part, it swaps  |
|                         |                     | out the template. It contains nearly the complete markup for the folder view    |
|                         |                     | consisting of the toolbar for the folder actions and the listing table. For the |
|                         |                     | batching support it pulls the helper template `batching.pt`.
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| Move                    | -                   | Handler for the XH requests for the manual folder reordering.                   |
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| Sort                    | -                   | Handler for the static folder sorting.                                          |
|-------------------------|---------------------|---------------------------------------------------------------------------------|
| JUpload                 | -                   | Backend for jQuery File Upload                                                  |

### Resources

The CSS and JavaScript files for the add-on are stored in *wildcard/foldercontents/resources*. Nearly without exception these are third-party components. They are combined and configured in *integration.js*.
