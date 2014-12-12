*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot

Library  Remote  ${PLONE_URL}/RobotRemote

Suite Setup  Setup
Suite Teardown  Teardown

*** Variables ***

${EMPTY_FOLDER_MESSAGE}  css=#folderlisting-main-table-noplonedrag p.discreet

*** Keywords ***

Setup
    Open test browser
    Set Window Size  1024  768
    Enable autologin as  Manager
    Go to  ${PLONE_URL}
    Add folder  test

Teardown
    Go to  ${PLONE_URL}/test
    Click Delete Action
    Close all browsers

*** Test Cases ***

Check Empty Folder Interface
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Capture Page Screenshot
    # Check the presence of the empty folder message
    Element Should Contain  ${EMPTY_FOLDER_MESSAGE}  This folder has no visible items.

    # Check that we have a 'Upload' and 'Sort' button
    Element Should Be Visible  upload-files
    Element Should Be Visible  sort-folder
    # Check that these are the only buttons
    Element Should Not Be Visible  name=folder_copy:method
    Element Should Not Be Visible  name=folder_cut:method
    Element Should Not Be Visible  name=folder_paste:method
    Element Should Not Be Visible  name=folder_status_history:method
    Element Should Not Be Visible  name=folder_rename_form:method

