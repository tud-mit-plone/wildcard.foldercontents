from plone.folder.interfaces import IOrderableFolder
from plone.folder.interfaces import IOrdering
from Products.CMFCore.utils import getToolByName
from zope.interface import implements
from zope.component import adapts
from wildcard.foldercontents.interfaces import ICatalogOrdering

class CatalogOrdering(object):
    """ordering for a folder by a catalog index"""

    implements(ICatalogOrdering)
    adapts(IOrderableFolder)

    def __init__(self, context):
        self.context = context

    def notifyAdded(self, id):
        """not needed here"""
        pass

    def notifyRemoved(self, id):
        """not needed here"""
        pass

    def getObjectPosition(self, id):
        """ Get the position of the given id """
        return self.idsInOrder.index(id)

    def idsInOrder(self):
        """ Return all object ids, in the correct order """
        return [brain.id for brain in self.query_brains()]

    def query_brains(self):
        """returns brains for all content items in the folder"""
        settings = self.settings()
        catalog = getToolByName(self.context, 'portal_catalog')
        brains = catalog.unrestrictedSearchResults(
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
        """returns the order settings"""
        return getattr(self.context, '__static_sort', {})
