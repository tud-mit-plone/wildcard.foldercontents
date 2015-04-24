from plone.testing import z2
from plone.app.testing import PLONE_FIXTURE
from plone.app.testing import applyProfile
from plone.app.testing import ploneSite
from plone.app.testing import quickInstallProduct
from plone.app.testing import FunctionalTesting
from plone.app.testing import PloneSandboxLayer
from plone.app.robotframework.testing import AUTOLOGIN_LIBRARY_FIXTURE

from Products.CMFCore.utils import getToolByName

from zope.configuration import xmlconfig

class WildcardFoldercontentsLayer(PloneSandboxLayer):

    defaultBases = (PLONE_FIXTURE,)

    def setUpZope(self, app, configurationContext):
        import wildcard.foldercontents
        xmlconfig.file(
            'testing.zcml',
            wildcard.foldercontents,
            context=configurationContext
        )

    def setUpPloneSite(self, portal):
        self.applyProfile(portal, 'wildcard.foldercontents:default')
        self.applyProfile(portal, 'wildcard.foldercontents:test')

FIXTURE = WildcardFoldercontentsLayer()

ROBOT_TESTING = FunctionalTesting(
    bases=(AUTOLOGIN_LIBRARY_FIXTURE,
           z2.ZSERVER_FIXTURE,
           FIXTURE, ),
    name="WildcardFoldercontents:Robot")
