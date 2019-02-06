import click
from patch_manager import PatchManager

@click.command()
@click.option('--patchmanager', nargs=1, type=click.Choice(['describe-instances', 'apply-tag', 'apply-patch', 'describe-compliance']))
def cli(patchmanager):
    if patchmanager == "describe-instances":
        pmObj = PatchManager()
        pmObj.listInstances()

    if patchmanager == "apply-tag":
        pmObj = PatchManager()
        pmObj.applyTag()

    if patchmanager == "apply-patch":
        pmObj = PatchManager()
        pmObj.applyPatch()

    if patchmanager == "describe-compliance":
        pmObj = PatchManager()
        pmObj.describeCompliance()