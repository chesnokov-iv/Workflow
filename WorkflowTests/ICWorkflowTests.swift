import XCTest
@testable import Mutualink_LNK360

class ICWorkflowTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_execute() throws {

        var testWorkflow: ICWorkflow? = ICWorkflow(withName: "A workflow's execution test")
        
        var deletionObject: NSObject? = NSObject()
        let deletionSensor = ICWFDeletionSensor(withObjectToWatch: deletionObject)
        
        testWorkflow?.registerArtifact(deletionObject)
        
        deletionObject = nil
        
        var stepsDeletionSensors: [ICWFDeletionSensor] = []
        
        let actualExecutionSequence = NSMutableArray()
        let expectedExecutionSequence: NSMutableArray = ["1", "2", "3"] as NSMutableArray
        
        for expectedSequenceItem in expectedExecutionSequence {
            if let expectedSequenceString = expectedSequenceItem as? NSString {
                let stepsDeletionSensor = ICWFDeletionSensor(
                    withObjectToWatch: testWorkflow?.firstStep(
                        is: ICWFTestableStep(
                            withDescription: expectedSequenceString,
                            and: actualExecutionSequence
                        )
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
        print("ICWF: TEST FINISHED")
    }
}
