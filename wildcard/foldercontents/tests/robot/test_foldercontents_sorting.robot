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
    # Drag and Drop has problems in Firefox, use phantomjs instead.
    Open Browser  ${PLONE_URL}  phantomjs
    Set Window Size  1024  768
    Enable autologin as  Manager
    Go to  ${PLONE_URL}
    Add folder  test
    Go to  ${PLONE_URL}/test
    Add Page  doc 3
    Go to  ${PLONE_URL}/test
    Add Page  doc 1
    Go to  ${PLONE_URL}/test
    Add Page  doc 2

Teardown
    Go to  ${PLONE_URL}/test
    Click Delete Action
    Close all browsers

Set Folder Order
    [Arguments]  ${criterium}  ${reverse}=${false}
    Click Link  sort-folder
    Select From List  css=#sort-container select  ${criterium}
    Run Keyword If  ${reverse}  Select Checkbox  reversed
    Click Button  Set Folder Order


*** Test Cases ***

Check Natural Sorting
    [Documentation]  The folder should list its content in the physical order by default.
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 2
    Click Entry In Display Sort Menu  Descending order
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 3

Check Display Sorting
    [Documentation]  See we can temporarily display the folder ordered by various criteria.
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Display Sort Menu  Title
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 1
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 3
    Log  Check manual reordering is deactivated
    Element Should Not Be Visible  foldercontents-order-column
    Click Entry In Display Sort Menu  Descending order
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 1
    Click Entry In Display Sort Menu  Ascending order

Check Manual Reordering
    [Documentation]  Test it is possible to reorder folder items with drag and drop.
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Display Sort Menu  Folder Order
    Drag And Drop  folder-contents-item-doc-2  folder-contents-item-doc-3
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 1
    Log  New order should survive page reload, see if the backend persisted the changes
    Reload Page
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 1

Test Static Folder Ordering
    [Documentation]  Check the support for pernament sortig after one criteria.
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Log  Switch to Title Sort
    Set Folder Order  Title
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 1
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 3
    Log  Check manual reordering is deactivated
    Element Should Not Be Visible  foldercontents-order-column
    Open Doc Menu  doc-1
    Page Should Not Contain Link  Move to top
    Page Should Not Contain Link  Move to bottom
    Log  Test sort order reflects new content
    Go to  ${PLONE_URL}/test
    Add Page  doc 0
    Go to  ${PLONE_URL}/test
    Add Page  doc 4
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 0
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 2
    Table Row Should Contain  listing-table  4  doc 3
    Table Row Should Contain  listing-table  5  doc 4
    Log  Return to Manual ordering
    Set Folder Order  Manual
    Capture Page Screenshot
    Log  The old content should appear in the original order ...
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 2
    Log  ... and the new at the end in order of creation
    Table Row Should Contain  listing-table  4  doc 0
    Table Row Should Contain  listing-table  5  doc 4
    Log  Now try with reversed Order
    Set Folder Order  Title  reverse=${true}
    Table Row Should Contain  listing-table  1  doc 4
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 2
    Table Row Should Contain  listing-table  4  doc 1
    Table Row Should Contain  listing-table  5  doc 0
