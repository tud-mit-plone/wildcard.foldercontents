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

Click Entry In Sort Menu
    [Arguments]  ${name}

    Click Button  css=#foldercontents-display-sortorder>button
    Element Should Contain  css=#foldercontents-display-sortorder>ul  ${name}
    Click Link  link=${name}
    Wait For Ajax Reload

Set Folder Order
    [Arguments]  ${criterium}  ${reverse}=${false}
    Click Link  sort-folder
    Select From List  css=#sort-container select  ${criterium}
    Run Keyword If  ${reverse}  Select Checkbox  reversed
    Click Button  Set Folder Order


*** Test Cases ***

Check Natural Sorting
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 2
    Click Entry In Sort Menu  Descending order
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 3
    Click Entry In Sort Menu  Ascending order

Check Display Sorting
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Sort Menu  Title
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 1
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 3
    # Check manual reordering is deactivated
    Element Should Not Be Visible  foldercontents-order-column
    Click Entry In Sort Menu  Descending order
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 1
    Click Entry In Sort Menu  Ascending order

Check Manual Reordering
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Sort Menu  Folder Order
    Drag And Drop  folder-contents-item-doc-2  folder-contents-item-doc-3
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 1
    # New order should survive page reload, see if the backend persisted the changes
    Reload Page
    Table Row Should Contain  listing-table  1  doc 2
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 1

Test Static Folder Ordering
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    # Switch to Title Sort
    Set Folder Order  Title
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 1
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 3
    # Check manual reordering is deactivated
    Element Should Not Be Visible  foldercontents-order-column
    Open Doc Menu  doc-1
    Page Should Not Contain Link  Move to top
    Page Should Not Contain Link  Move to bottom
    # Test sort order reflects new content
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
    # Return to Manual ordering
    Set Folder Order  Manual
    Capture Page Screenshot
    # The old content should appear in the original order ...
    Table Row Should Contain  listing-table  1  doc 3
    Table Row Should Contain  listing-table  2  doc 1
    Table Row Should Contain  listing-table  3  doc 2
    # ... and the new at the end in order of creation
    Table Row Should Contain  listing-table  4  doc 0
    Table Row Should Contain  listing-table  5  doc 4
    # Now try with reversed Order
    Set Folder Order  Title  reverse=${true}
    Table Row Should Contain  listing-table  1  doc 4
    Table Row Should Contain  listing-table  2  doc 3
    Table Row Should Contain  listing-table  3  doc 2
    Table Row Should Contain  listing-table  4  doc 1
    Table Row Should Contain  listing-table  5  doc 0
