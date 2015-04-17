/*jslint browser: true */
/*jslint unparam: true */
/*jslint nomen: true */
/*global $, jQuery */

var id_prefix = 'folder-contents-item-';
var container_id = 'folderlisting-main-table-noplonedrag';
var load_more_locked = false;
var last_folder_url = window.location.href;
var shifted = false;
var last_checked = null;
var fc;

fc = {
    sortable: function() {
        var sort_on = $('#foldercontents-order-column').data('sort_on');
        return sort_on === undefined || sort_on === '' || sort_on === 'getObjPositionInParent';
    },
    showLoading: function() {
        $('#kss-spinner').show();
    },
    hideLoading: function() {
        $('#kss-spinner').hide();
    },
    moveItem: function(row, params, callback) {
        fc.showLoading();
        params.itemid = row.attr('id').substring(id_prefix.length);
        if (params.action === undefined) {
            params.action = 'movedelta';
        }
        params['_authenticator'] = $('input[name="_authenticator"]').attr('value');
        $.ajax({
            type: 'POST',
            url: $('div.fc-container').data('contextBaseUrl') + '@@fcmove',
            data: params,
            success: function() {
                if (callback !== undefined) {
                    callback();
                }
                fc.hideLoading();
            },
            failure: function() {
                console.log('fail');
                fc.hideLoading();
            }
        });
    },
    reloadPage: function() {
        fc.showLoading();
        $.ajax({
            url: last_folder_url,
            success: function(data) {
                $('#content-core').replaceWith($($.parseHTML(data)).find('#content-core'));
                fc.hideLoading();
                fc.initialize();
            }
        });
    },
    setUploadFormVisibility: function(visible) {
        if (visible) {
            $('#fileupload').fadeIn()[0].scrollIntoView();
            $('#upload-files').addClass('active');
            fc.setSortContainerVisibility(false);
        }
        else {
            $('#fileupload').fadeOut();
            $('#upload-files').removeClass('active');
        }
    },
    setSortContainerVisibility: function(visible) {
        if (visible) {
            $('#sort-container').fadeIn()[0].scrollIntoView();
            $('#sort-folder').addClass('active');
            fc.setUploadFormVisibility(false);
        }
        else {
            $('#sort-container').fadeOut();
            $('#sort-folder').removeClass('active');
        }
    },
    initialize: function() {
        // ajaxify some links
        $('#content-core').delegate('#foldercontents-selectall,#foldercontents-selectall-completebatch,#foldercontents-show-batched,.listingBar a,#foldercontents-clearselection,#foldercontents-show-all,#foldercontents-display-sortorder a',
            'click', function() {
                fc.showLoading();
                last_folder_url = $(this).attr('href');
                $.ajax({
                    url: last_folder_url,
                    success: function(data) {
                        $('#' + container_id).replaceWith(
                            $($.parseHTML(data)).find('#' + container_id));
                        fc.hideLoading();
                        fc.initializeTable();
                    }
                });
                return false;
        });
        $('#content-core').delegate('.move-top', 'click', function() {
            fc.showLoading();
            var el = $(this).parents('tr');
            fc.moveItem(el, {
                action: 'movetop'
            }, fc.reloadPage);
            return false;
        });

        $('#content-core').delegate('.move-bottom', 'click', function() {
            fc.showLoading();
            var el = $(this).parents('tr');
            fc.moveItem(el, {
                action: 'movebottom'
            }, fc.reloadPage);
            return false;
        });


        $('#content-core').delegate('#listing-table input[type="checkbox"]', 'change', function(event) {
            if (shifted && last_checked !== null) {
                var self, last_checked_index, this_index;
                //find closest sibling
                self = $(this);
                last_checked_index = last_checked.parents('tr').index();
                this_index = self.parents('tr').index();
                $('#listing-table input[type="checkbox"]').each(function() {
                    var el, index;
                    el = $(this);
                    index = el.parents('tr').index();
                    if ((index > last_checked_index && index < this_index) ||
                        (index < last_checked_index && index > this_index)) {
                        this.checked = self[0].checked;
                    }
                });
            } else {
                last_checked = $(this);
            }
        });

        fc.initializeTable();
    },

    initializeTable: function()
    {
        $('#upload-files').click(function() {
            fc.setUploadFormVisibility(!$('#upload-files').hasClass('active'));
            return false;
        });
        $('#sort-folder').click(function() {
            fc.setSortContainerVisibility(!$('#sort-folder').hasClass('active'));
            return false;
        });
        var start = null;
        if (fc.sortable()) {
            $('#listing-table tbody').sortable({
                forcePlaceholderSize: true,
                placeholder: "sortable-placeholder",
                forceHelperSize: true,
                helper: "clone",
                start: function(event, ui) {
                    var origtds, helpertds;
                    // show original, get width, then hide again
                    ui.item.css('display', '');
                    origtds = ui.item.find('td');
                    helpertds = ui.helper.find('td');
                    origtds.each(function(index) {
                        helpertds.eq(index).css('width', $(this).width());
                    });
                    ui.item.css('display', 'none');
                    start = ui.item.index();
                },
                update: function(event, ui) {
                    fc.moveItem(ui.item, {
                        delta: ui.item.index() - start
                    });
                },
                change: function(event, ui) {
                    var rows, next;
                    if (load_more_locked) {
                        return;
                    }
                    rows = $('#listing-table tbody tr');
                    if ((ui.placeholder.index() + 3) > rows.length) {
                        next = $('.listingBar .next a');
                        if (next.length > 0) {
                            load_more_locked = true;
                            $.ajax({
                                url: next.attr('href'),
                                success: function(data) {
                                    var html = $.parseHTML(data);
                                    $('.listingBar').replaceWith(html.find('.listingBar').eq(0));
                                    $('#listing-table tbody').append(
                                        html.find('#listing-table tbody tr'));
                                    if (fc.sortable()) {
                                        $('#listing-table tbody').sortable('refresh');
                                    }
                                    load_more_locked = false;
                                }
                            });
                        }
                    }
                }
            });
        }

        $('.dropdown-toggle').dropdown();

        $('#listing-table a.actionicon-object_buttons-delete').prepOverlay(
            {
                 subtype: 'ajax',
                 filter: common_content_filter,
                 formselector: '#delete_confirmation',
                 cssclass: 'overlay-delete',
                 noform: 'reload',
                 closeselector: '[name="form.button.Cancel"]',
                 width:'50%'
             }
        );

        $('#listing-table a.actionicon-object_buttons-rename').prepOverlay(
            {
                 subtype: 'ajax',
                 filter: common_content_filter,
                 cssclass: 'overlay-rename',
                 closeselector: '[name="form.button.Cancel"]',
                 width:'40%'
             }
        );
    }
};

(function($) {
    $(document).ready(function() {
        fc.initialize();
        $(document).bind('keyup keydown', function(e) {
            shifted = e.shiftKey;
        });

        $('#fileupload').fileupload({
            'limitConcurrentUploads': 2,
            'singleFileUploads': true,
            'dataType': 'json',
            'formData': {
                '_authenticator': $('input[name="_authenticator"]').attr('value')
            }
        }).bind('fileuploadstop', function(e, data)
        {
            // clear the upload queue
            $('#fileupload table tbody.files').empty();
            // then reload the table
            fc.reloadPage();
            // finally hide the form
            fc.setUploadFormVisibility(false);
        });
    });
}(jQuery));
