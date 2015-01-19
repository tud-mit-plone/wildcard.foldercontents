from persistent.mapping import PersistentMapping
from plone.folder.interfaces import IOrderableFolder
from plone.folder.interfaces import IOrdering
from Products.CMFCore.utils import getToolByName
from zope.annotation.interfaces import IAnnotations
from zope.interface import implements
from zope.component import adapts
from zope.component import getAdapter
from wildcard.foldercontents.interfaces import ICatalogOrdering

class CatalogOrdering(object):
    """ordering for a folder by a catalog index"""

    implements(ICatalogOrdering)
    adapts(IOrderableFolder)

    SETTINGS_KEY = 'wildcard.foldercontents.CatalogOrderingSettings'

    def __init__(self, context):
        self.context = context

    def notifyAdded(self, id):
        """tell the default order about the new ID

        Here we don't need it, since we rely on the automatically
        updated catolog. But the default ordering needs to be told
        or the listing is out of date when the user
        uses it again for the folder.
        """
        self._get_default_ordering().notifyAdded(id)


    def notifyRemoved(self, id):
        """see notifyAdded"""
        self._get_default_ordering().notifyRemoved(id)

    def getObjectPosition(self, id):
        """ Get the position of the given id """
        return self.idsInOrder().index(id)

    def idsInOrder(self):
        """ Return all object ids, in the correct order """
        return [brain.id for brain in self.query_brains()]

    def query_brains(self):
        """returns brains for all content items in the folder"""
        settings = self.settings()
        catalog = getToolByName(self.context, 'portal_catalog')
        brains = catalog(
            path={
                'query': '/'.join(self.context.getPhysicalPath()),
                'depth': 1,
            },
            show_inactive=True,
            sort_on=settings.get('criterium', '')
        )
        if settings.get('reversed', False):
            brains = [b for b in reversed(brains)]
        return brains

    def settings(self):
        """returns the ordering settings stored in an annotation"""
        annotations = IAnnotations(self.context)
        settings = annotations.get(self.SETTINGS_KEY, None)
        if settings is None:
            settings = annotations[self.SETTINGS_KEY] = PersistentMapping()
        return settings
    def _get_default_ordering(self):
        return getAdapter(self.context, IOrdering, name='')

