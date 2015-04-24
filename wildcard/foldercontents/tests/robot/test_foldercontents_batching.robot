*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot
Resource  ./shared.robot

Library  Remote  ${PLONE_URL}/RobotRemote

Suite Setup  Setup
Suite Teardown  Teardown

*** Variables ***

*** Keywords ***

Setup
    Open test browser
    Set Window Size  1024  768
    Enable autologin as  Manager
    Go to  ${PLONE_URL}
    Add folder  test
    : FOR  ${index}  IN RANGE  1  43
    \   Go to  ${PLONE_URL}/test
    \   Add Page  doc ${index}

Teardown
    Go to  ${PLONE_URL}/test
    Click Delete Action
    Close all browsers

*** Test Cases ***

Check Batching
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    # Check presence of batching UI
    Element Should Be Visible  css=.listingBar  Batching interface missing
    Element Should Contain  css=.listingBar  1  Element for first page missing
    Element Should Contain  css=.listingBar  2  Element for second page missing
    Element Should Contain  css=.listingBar  3  Element for third page missing
    Element Should Contain  css=.listingBar  Next 20 items  Next batch link missing
    Capture Page Screenshot
    # Check first batch
    : FOR  ${index}  IN RANGE  1  20
    \   Table Row Should Contain  listing-table  ${index}  doc ${index}
    # Go to next batch
    Click Link  css=.listingBar .next a
    Wait For Ajax Reload
    Element Should Be Visible  css=.listingBar  Previous 20 items
    Table Row Should Contain  listing-table  1  doc 21
    # Go to third and last batch
    Click Link  3
    Wait For Ajax Reload
    Element Should Not Be Visible  css=.listingBar .next a
    Table Row Should Contain  listing-table  1  doc 41
    # Return to first batch
    Click Link  1
    Wait For Ajax Reload
    Table Row Should Contain  listing-table  1  doc 1
    # Now reverse the display sort order
    Click Entry In Display Sort Menu  Descending order
    Table Row Should Contain  listing-table  1  doc 42


Check Batch Selection
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Link  foldercontents-selectall
    Wait For Ajax Reload
    Element Should Contain  css=#listing-table thead  All 20 items on this page are selected.
    Click Link  foldercontents-selectall-completebatch
    Wait For Ajax Reload
    Element Should Contain  css=#listing-table thead  All 42 items in this folder are selected.
    Click Link  foldercontents-clearselection
    Wait For Ajax Reload
    Element Should Contain  css=#listing-table thead  Select


Check Complete Listing
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Link  foldercontents-show-all
    Wait For Ajax Reload
    : FOR  ${index}  IN RANGE  1  43
    \   Table Row Should Contain  listing-table  ${index}  doc ${index}
    Click Link  foldercontents-show-batched
    Wait For Ajax Reload
    Element Should Be Visible  foldercontents-show-all

Check Batch Deletion
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Link  foldercontents-selectall
    Wait For Ajax Reload
    Click Link  foldercontents-selectall-completebatch
    Wait For Ajax Reload
    Click Button  Delete
    Element Should Contain  content-core  This folder has no visible items.
