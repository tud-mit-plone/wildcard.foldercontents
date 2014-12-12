*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot

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
    Delete Content  test
    Close all browsers

Click Entry In Sort Menu
    [Arguments]  ${name}

    Click Button  css=#foldercontents-display-sortorder>button
    Element Should Contain  css=#foldercontents-display-sortorder>ul  ${name}
    Click Link  link=${name}

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

Check Sorting By Title
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Sort Menu  Title
    Capture Page Screenshot
    Table Row Should Contain  listing-table  1  doc 1
    Table Row Should Contain  listing-table  2  doc 2
    Table Row Should Contain  listing-table  3  doc 3
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
