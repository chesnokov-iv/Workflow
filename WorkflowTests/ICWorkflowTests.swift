import XCTest
@testable import Mutualink_LNK360

class ICWorkflowTestCase: NSObject {
    var name: String = ""
    var initialExecutionSequence = NSMutableArray()
    var expectedExecutionSequence = NSMutableArray()
}

class ICWorkflowTests: XCTestCase {
    
    let BREAK_WORKFLOW = "0" as NSString

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_execute() throws {
        let wfTestCase = ICWorkflowTestCase()
        
        wfTestCase.name = "A workflow's execution test"
        wfTestCase.initialExecutionSequence = ["1", "2", "3"] as NSMutableArray
        wfTestCase.expectedExecutionSequence = ["1", "2", "3"] as NSMutableArray
        
        try verify_case(wfTestCase)
    }
    
    func test_cancel() throws {
        let wfTestCase = ICWorkflowTestCase()
        
        wfTestCase.name = "A workflow's cancellation test"
        wfTestCase.initialExecutionSequence = ["1", "2", BREAK_WORKFLOW, "3"] as NSMutableArray
        wfTestCase.expectedExecutionSequence = ["1", "2"] as NSMutableArray
        
        try verify_case(wfTestCase)
    }
    
    func verify_case(_ wfTestCase: ICWorkflowTestCase) throws {

        var testWorkflow: ICWorkflow? = ICWorkflow(withName: wfTestCase.name, logger: ICDebugLogger())
        
        var deletionObject: NSObject? = NSObject()
        let deletionSensor = ICWFDeletionSensor(withObjectToWatch: deletionObject)
        
        testWorkflow?.registerArtifact(deletionObject)
        
        deletionObject = nil
        
        var stepsDeletionSensors: [ICWFDeletionSensor] = []
        
        let actualExecutionSequence = NSMutableArray()
        let initialExecutionSequence =  wfTestCase.initialExecutionSequence
        let expectedExecutionSequence = wfTestCase.expectedExecutionSequence
        
        for sequenceItem in initialExecutionSequence {
            if let expectedSequenceString = sequenceItem as? NSString {
                
                let step = stepFor(expectedSequenceString: expectedSequenceString, actualExecutionSequence: actualExecutionSequence)
                
                let stepsDeletionSensor = ICWFDeletionSensor(
                    withObjectToWatch: testWorkflow?.firstStep(
                        is: step
                    )
                )
                stepsDeletionSensors.append(stepsDeletionSensor)
            }
        }

        testWorkflow?.endFlow()

        testWorkflow?.execute()
        testWorkflow = nil // We have to release testWorkflow locally to see how the workflow will clean by itself
        
        let exp = expectation(description: "")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            guard deletionSensor.objectToWatch == nil else {
                XCTFail("ICWF: We have memory leaks")
                return
            }
            
            XCTAssertTrue(expectedExecutionSequence == actualExecutionSequence, "ICWF: Incorrect executions order")
            
            for stepsDeletionSensor in stepsDeletionSensors where stepsDeletionSensor.objectToWatch != nil {
                XCTFail("ICWF: We have memory leaks. Some of steps was not deleted")
                break
            }
            
            exp.fulfill()
        })

        self.waitForExpectations(timeout: 3.0)
        testWorkflow?.logger.log("ICWF: TEST FINISHED")
    }

    func stepFor(expectedSequenceString: NSString, actualExecutionSequence: NSMutableArray) -> ICWFStep {
        switch expectedSequenceString {
            case BREAK_WORKFLOW:
                return ICWFCancellationStep()
                
            default:
                return ICWFTestableStep(
                    withDescription: expectedSequenceString,
                    and: actualExecutionSequence
                )
        }
    }
}
