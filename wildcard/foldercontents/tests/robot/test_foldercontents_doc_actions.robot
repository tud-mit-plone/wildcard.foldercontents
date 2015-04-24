*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot
Resource  ./shared.robot

Library  Remote  ${PLONE_URL}/RobotRemote

Suite Setup  Setup Suite
Suite Teardown  Teardown Suite

*** Variables ***

*** Keywords ***

Setup Suite
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

Teardown Suite
    Go to  ${PLONE_URL}/test
    Click Delete Action
    Close all browsers

Test Cutting
    Capture Page Screenshot
    Click Entry In Doc Menu  doc-1  cut
    # check we're still here
    Element Should Contain  css=h1.documentFirstHeading  test
    Element Should Be Visible  listing-table
    # check the action's message
    Check Status Message  doc 1 cut.

Test Copying
    Capture Page Screenshot
    Click Entry In Doc Menu  doc-1  copy
    # check we're still here
    Element Should Contain  css=h1.documentFirstHeading  test
    Element Should Be Visible  listing-table
    # check the action's message
    Check Status Message  doc 1 copied.

Test Pasting
    Capture Page Screenshot
    Click Entry In Doc Menu  doc-1  paste
    # check we're still here
    Element Should Contain  css=h1.documentFirstHeading  test
    Element Should Be Visible  listing-table
    # check the action's message
    Check Status Message  Item(s) pasted.
    # check the folder has a copy of doc-1
    Element Should Be Visible  folder-contents-item-copy_of_doc-1


*** Test Cases ***

Test Popup Auto Closing
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Open Doc Menu  doc-1
    Open Doc Menu  doc-2
    Doc Menu Should Not Be Visible  doc-1

Test Renaming
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Doc Menu  doc-1  rename
    Verify Overlay Is Visible
    Click Button  Rename All
    Verify Overlay Is Gone
    # check we're back
    Element Should Contain  css=h1.documentFirstHeading  test
    Element Should Be Visible  listing-table
    # check the action's message
    Check Status Message  0 item(s) renamed.

Test Clipboard Actions
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Test Cutting
    Test Copying
    Test Pasting

Test Deleting
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Doc Menu  doc-1  delete
    Verify Overlay Is Visible
    Click Button  xpath=//form[@id='delete_confirmation']//input[@type='submit' and @value='Delete']
    Verify Overlay Is Gone
    # check we're back
    Element Should Contain  css=h1.documentFirstHeading  test
    Element Should Be Visible  listing-table
    # check doc-1 isn't listed anymore
    Element Should Not Be Visible  folder-contents-item-doc-1
