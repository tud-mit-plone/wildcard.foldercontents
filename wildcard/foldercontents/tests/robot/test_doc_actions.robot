*** Settings ***

Resource  plone/app/robotframework/selenium.robot
Resource  plone/app/robotframework/keywords.robot

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

Click Entry In Doc Menu
    [Arguments]  ${doc-id}  ${action-id}

    Click Button  css=#folder-contents-item-${doc-id} button.dropdown-toggle
    Click Link  css=#folder-contents-item-${doc-id} ul.dropdown-menu a.actionicon-object_buttons-${action-id}

Verify Overlay Is Visible
    Wait until keyword succeeds  10  1  Page Should Contain Element  css=.pb-ajax > div
    Element Should Be Visible  css=.pb-ajax > div

Verify Overlay Is Gone
    Wait until keyword succeeds  10  1  Page Should Not Contain Element  css=.pb-ajax > div

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

Test Renaming
    Go to  ${PLONE_URL}/test
    Click Contents In Edit Bar
    Click Entry In Doc Menu  doc-1  rename
    # check that we have navigated to 'doc 1' ...
    Element Should Contain  breadcrumbs-current  doc 1
    # ... and we are indeed on it's rename form
    Element Should Contain  css=h1.documentFirstHeading  Rename item
    Click Button  Rename All
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
