from plone.folder.interfaces import IOrdering
from zope.filerepresentation.interfaces import IFileFactory
from zope.interface import Interface


class ILayer(Interface):
    pass


class IATCTFileFactory(IFileFactory):
    """Adapter factory for ATCT
    """


class IDXFileFactory(IFileFactory):
    """Adapter factory for DX types
    """

class ICatalogOrdering(IOrdering):
    """A folder ordering adapter based on a catalog criterium"""

    def settings():
        """retrieve the settings dict controllint the search behavior"""
