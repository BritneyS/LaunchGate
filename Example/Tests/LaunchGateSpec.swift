import Quick
import Nimble

@testable import LaunchGate

class LaunchGateSpec: QuickSpec {
  override func spec() {

    let exampleURI = "https://www.example.com/example.json"

    describe("#init") {
      
      it("the URI is stored in the remote file manager") {
        let launchGate = LaunchGate(uri: exampleURI)

        expect(launchGate.configurationFileURI) == exampleURI
      }
      
    }

    describe("#performCheck") {

      class MockLaunchGateRemoteFileManager : LaunchGateRemoteFileManager {
        var fetchRemoteFileWasCalled = false

        override func fetchRemoteFile(callback: (NSData) -> Void) {
          fetchRemoteFileWasCalled = true
        }
      }
      
      var mockRemoteFileManager: MockLaunchGateRemoteFileManager!
      
      beforeEach {
        mockRemoteFileManager = MockLaunchGateRemoteFileManager(remoteFileURIString: exampleURI)
      }
      
      it("the URI is stored in the remote file manager") {
        let launchGate = LaunchGate(uri: exampleURI)
        
        launchGate.performCheck(mockRemoteFileManager)
        
        expect(mockRemoteFileManager.remoteFileURI?.absoluteString) == exampleURI
      }

      it("calls LaunchGateRemoteFileManager#fetchRemoteFile") {
        let launchGate = LaunchGate(uri: exampleURI)

        launchGate.performCheck(mockRemoteFileManager)

        expect(mockRemoteFileManager.fetchRemoteFileWasCalled) == true
      }

    }
    
    describe("#displayDialogIfNecessary") {
      
      class MockLaunchGate: LaunchGate {
        
        override func currentAppVersion() -> String? {
          return "1.0"
        }
        
      }
      
      class MockLaunchGateDialogManager: LaunchGateDialogManager {
        var displayAlertDialogWasCalled = false
        var displayRequiredUpdateDialogWasCalled = false
        var displayOptionalUpdateDialogWasCalled = false
        
        override func displayAlertDialog(message: String) { displayAlertDialogWasCalled = true }
        override func displayRequiredUpdateDialog(message: String) { displayRequiredUpdateDialogWasCalled = true }
        override func displayOptionalUpdateDialog(message: String) { displayOptionalUpdateDialogWasCalled = true }
      }
      
      var launchGate: MockLaunchGate!
      var dialogManager: MockLaunchGateDialogManager!
      var config: LaunchGateConfiguration!
      
      beforeEach {
        launchGate = MockLaunchGate(uri: "")
        dialogManager = MockLaunchGateDialogManager()
        config = LaunchGateConfiguration()
      }
      
      context("when the app is elligible for a required update") {
        
        it("displays a required update dialog") {
          config.requiredUpdate = LaunchGateUpdateConfiguration(version: "1.1", message: "Update required!")
          
          launchGate.displayDialogIfNecessary(config, dialogManager: dialogManager)
          
          expect(dialogManager.displayRequiredUpdateDialogWasCalled) == true
        }
        
      }
      
      context("when the app is elligible for an optional update") {
        
        it("displays an optional update dialog") {
          config.optionalUpdate = LaunchGateUpdateConfiguration(version: "1.2", message: "Optional update availabe.")
          
          launchGate.displayDialogIfNecessary(config, dialogManager: dialogManager)
          
          expect(dialogManager.displayOptionalUpdateDialogWasCalled) == true
        }
        
      }
      
      context("when an alert should be displayed") {
        
        it("displays an alert dialog") {
          config.alert = LaunchGateAlertConfiguration(message: "Hello world", blocking: false)
          
          launchGate.displayDialogIfNecessary(config, dialogManager: dialogManager)
          
          expect(dialogManager.displayAlertDialogWasCalled) == true
        }
        
      }
      
    }
    
    describe("#shouldShowUpdateDialog") {
      
      var launchGate: LaunchGate!
      let updateConfig = LaunchGateUpdateConfiguration(version: "1.1", message: "")
      
      beforeEach {
        launchGate = LaunchGate(uri: "")
      }
      
      it("when the app version is less than the update version, returns true") {
        let result = launchGate.shouldShowUpdateDialog(updateConfig, appVersion: "1.0")
        
        expect(result) == true
      }
      
      it("when the app version is greater than the update version, returns falses") {
        let result = launchGate.shouldShowUpdateDialog(updateConfig, appVersion: "1.2")
        
        expect(result) == false
      }
      
      it("when the app version is equal to the update version, returns false") {
        let result = launchGate.shouldShowUpdateDialog(updateConfig, appVersion: "1.1")
        
        expect(result) == false
      }
      
    }
    
    describe("#shouldShowAlertDialog") {
      
      var launchGate: LaunchGate!
      
      beforeEach {
        launchGate = LaunchGate(uri: "")
      }
      
      it("when the alert message is not empty, returns true") {
        let alertConfig = LaunchGateAlertConfiguration(message: "Hello world", blocking: false)
        let result = launchGate.shouldShowAlertDialog(alertConfig)
        
        expect(result) == true
      }
      
      it("when the alert message is empty, returns false") {
        let alertConfig = LaunchGateAlertConfiguration(message: "", blocking: false)
        let result = launchGate.shouldShowAlertDialog(alertConfig)
        
        expect(result) == false
      }
      
    }

  }
}
