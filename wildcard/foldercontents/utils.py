from plone.folder.interfaces import IExplicitOrdering
from Products.CMFCore.utils import getToolByName
from Products.CMFPlone.interfaces.siteroot import IPloneSiteRoot

def sort_folder(context, sort_crit, sort_reversed):
    ordering = getOrdering(context)
    catalog = getToolByName(context, 'portal_catalog')
    brains = catalog(path={
        'query': '/'.join(context.getPhysicalPath()),
        'depth': 1
    }, sort_on=sort_crit)
    if sort_reversed:
        brains = [b for b in reversed(brains)]
    for idx, brain in enumerate(brains):
        ordering.moveObjectToPosition(brain.id, idx)

def getOrdering(context):
    if IPloneSiteRoot.providedBy(context):
        return context
    else:
        ordering = context.getOrdering()
        if not IExplicitOrdering.providedBy(ordering):
            return None
        return ordering
