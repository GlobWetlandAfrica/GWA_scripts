from qgis.PyQt.QtCore import QCoreApplication, Qt
from qgis.processing import alg
from qgis.utils import iface
from qgis.core import (QgsProcessingAlgorithm,
                       QgsProcessingParameterBoolean,
                       QgsProcessingOutputBoolean)
try:
    from ThRasE.thrase import ThRasE
    from ThRasE.gui.main_dialog import ThRasEDialog
    thrase_installed = True
except ImportError:
    thrase_installed = False

# Cannot use @alg decorator because we need to set no-threding flag to parse HTML properly
class RunThRasE(QgsProcessingAlgorithm):

    def tr(self, string):
        """
        Returns a translatable string with the self.tr() function.
        """
        return QCoreApplication.translate('Processing', string)

    def createInstance(self):
        # Must return a new copy of your algorithm.
        return RunThRasE()

    def name(self):
        """
        Returns the unique algorithm name.
        """
        return 'runthrase'

    def displayName(self):
        """
        Returns the translated algorithm name.
        """
        return self.tr('Run ThRasE Tool')

    def group(self):
        """
        Returns the name of the group this algorithm belongs to.
        """
        return self.tr('Generic tools')

    def groupId(self):
        """
        Returns the unique ID of the group this algorithm belongs
        to.
        """
        return 'gt'

    def shortHelpString(self):
        """
        Returns a localised short help string for the algorithm.
        """
        return self.tr('Run ThRasE tool')

    def initAlgorithm(self, config=None):
        """
        Here we define the inputs and outputs of the algorithm.
        """
        self.addParameter(
            QgsProcessingParameterBoolean(
                'run_thrase',
                self.tr("Run ThRasE Tool"),
                True,
                optional=False
            )
        )
        
        self.addOutput(
            QgsProcessingOutputBoolean(
                'success'
            )
        )

    def flags(self):
        return super().flags() | QgsProcessingAlgorithm.FlagNoThreading

    def processAlgorithm(self, parameters, context, feedback):
        if thrase_installed:
            if self.parameterAsBool(parameters, "run_thrase", context) is True:
                feedback.setProgressText('Starting ThRasE plugin...')
                thrase = ThRasE(iface)
                ThRasE.dialog = ThRasEDialog()

                # connect to provide cleanup on closing of dialog
                ThRasE.dialog.closingPlugin.connect(thrase.onClosePlugin)

                # setup and show the dialog
                if ThRasE.dialog.setup_gui():
                    ThRasE.dialog.show()
                    ThRasE.dialog.setWindowState(ThRasE.dialog.windowState() & ~Qt.WindowMinimized | Qt.WindowActive)
                    ThRasE.dialog.raise_()
                    ThRasE.dialog.activateWindow()
                    # Run the dialog event loop
                    result = ThRasE.dialog.open()

            return {"success": True}
        else:
            feedback.reportError("ERROR: ThRasE plugin is not installed", fatalError=True)
            return {"success": False}
        
