import UIKit

open class ICWFStep: NSObject {

    public let nextStepChainLabel = "NextChain" as NSString

    public var index: Int = 0
    public var stepDescription: NSString?

    public var executor: ICWFStepExecutor?
    public var owner: ICWorkflow? {
        didSet {
            logger = owner?.logger
        }
    }
    
    public var logger: ICBaseLogger?

    public var input: NSObject?
    public var output: NSObject?

    private var _nextChain: ICWFChain!
    public var nextChain: ICWFChain { _nextChain }

    private var _allChains: [ICWFChain] = []
    public var chains: [ICWFChain] { _allChains }

    private var _isCompleted: Bool = false

    public override init() {
        super.init()
        _nextChain = newChain(nextStepChainLabel)
    }

    public func newChain(_ chainDescription_p: NSString) -> ICWFChain {
        let result = ICWFChain(withDescription: chainDescription_p)
        _allChains.append(result)
        return result
    }

    deinit {
#if ALWAYS_LOG_WORKFLOWS || DEBUG
        logger?.log("ICWF: The step '\(String(describing: description))' (\(NSStringFromClass(self.classForCoder))) is deallocating")
#endif
    }

    // Service method (used by executor). Don't call it directly or override it
    func _sys_make() {
        _isCompleted = false
        make()
    }
    
    open func make() {
        output = input
    }

    public func complete() {
        complete(withNextStep: nextChain.firstStep)
    }

    public func complete(withNextStep nextStep: ICWFStep?) {
        complete(withNextStep: nextStep, andResult: output)
    }

    public func complete(withNextStep nextStepObj: ICWFStep?, andResult result: NSObject?) {
        guard _isCompleted == false else {
            return
        }

        _isCompleted = true

        if let nextStep = nextStepObj {
            nextStep.input = result
            doNextStep(nextStep)
        }

        executor?.completeStep(self)
    }

    public func doNextStep(_ nextStep: ICWFStep?) {
        executor?.executeStep(nextStep)
    }

    public func safe(object obj: NSObject?, ofClass requiredClass: AnyClass) ->Any? {
        guard let testObject = obj else {
            return nil
        }
        return (testObject.isKind(of: requiredClass)) ? obj : nil
    }

    open override var description: String {
        guard let meaningfulDescription = stepDescription else {
            return "N/A"
        }
        return meaningfulDescription as String
    }

    open func cleanNewObject() -> AnyObject {
        return ICWFStep()
    }

    open func copyOfStep() -> AnyObject {
        let result = cleanNewObject()
        if let stepCopy = result as? ICWFStep {
            stepCopy.stepDescription = self.stepDescription
        }
        return result
    }
    
    open func stepDescriptionForErrors() -> String {
        guard let safeStepDescription = stepDescription else {
            return ""
        }
        
        if safeStepDescription.length < 2 {
            return safeStepDescription.lowercased
        }
        
        let result = String(format: "%@%@", safeStepDescription.substring(to: 1).lowercased(), safeStepDescription.substring(from: 1))
        return result
    }
}
