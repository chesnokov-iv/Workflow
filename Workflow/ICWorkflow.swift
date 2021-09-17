import UIKit

open class ICWorkflow: NSObject {

    private var _nameObj: String?
    public var name: String? { _nameObj }

    private var _firstStepObj: ICWFStep?
    public var firstStep: ICWFStep? { _firstStepObj }

    private var _lastStepObj: ICWFStep?

    private let _artifacts = NSMutableArray()
    private var _steps: [ICWFStep] = []
    private var _inProgress = false

    public init(withName name: String) {
        _nameObj = name
    }

    deinit {
        #if DEBUG
        let workflowName = self.name ?? "N/A"
        print("ICWF: The workflow '\(workflowName)' (\(NSStringFromClass(self.classForCoder))) is deallocating")
        #endif
    }

    public func firstStep(is firstStepObj: ICWFStep?) -> ICWFStep? {
        guard let firstStep = firstStepObj else {
            return nil
        }
        
        guard _firstStepObj == nil else {
            return nextStep(firstStepObj)
        }

        registerStep(firstStep)

        _firstStepObj = firstStep
        _lastStepObj = _firstStepObj

        return _firstStepObj
    }
    
    public func registerStep(_ step: ICWFStep) {
        _steps.append(step)
        
        step.owner = self

        if step.index == 0 {
            step.index = _steps.count
        }
    }

    public func nextStep(_ nextStepObj: ICWFStep?) -> ICWFStep? {
        return nextStep(for: _lastStepObj?.nextChain, is: nextStepObj)
    }

    public func nextStep(for targetChain: ICWFChain?, is nextStepObj: ICWFStep?) -> ICWFStep? {
        guard
            let targetChainObj = targetChain,
            targetChainObj.firstStep == nil,
            let nextStep = nextStepObj
        else {
            return nil
        }
        
        registerStep(nextStep)
        targetChain!.firstStep = nextStep
        _lastStepObj = nextStep
        return _lastStepObj
    }

    public func nextStepOnError(for currentStepObj: ICWFStepWithErrorChain?, is nextStepObj: ICWFStep?) -> ICWFStep? {
        return nextStep(for: currentStepObj?.errorHandlingChain, is: nextStepObj)
    }

    public func execute() {
        _inProgress = true
        let executor = ICWFStepExecutor()
        executor.executeStep(_firstStepObj)
    }

    static private var wfPool = NSMutableArray()
    static private let wfPoolLock = NSRecursiveLock()
    
    public func executeGlobally() {

        ICWorkflow.wfPoolLock.lock()
        ICWorkflow.wfPool.add(self)
        
        if ICWorkflow.wfPool.indexOfObjectIdentical(to: self) == 0 {
            // The workflow should be started, if it is the first item in the pool
            execute()
        }
        
        ICWorkflow.wfPoolLock.unlock()
    }
    
    public func registerArtifact(_ artifact: NSObject?) {
        guard let nonNilArtifact = artifact, _artifacts.indexOfObjectIdentical(to: nonNilArtifact) == NSNotFound else { return }
        _artifacts.add(nonNilArtifact)
    }

    public func loadValue(_ value: NSObject?) -> ICWFStep? {
        return ICWFInitWithValueStep(with: value)
    }

    public func endStep() -> ICWFStep? {
        return ICWFEndStep()
    }

    public func endFlow() {
        _ = nextStep(endStep())
    }

    // used by IMLWF2EndStep
    public func destroy() {
        for step in _steps {
            for chain in step.chains {
                chain.firstStep = nil
            }
            step.owner = nil
        }
        
        ICWorkflow.wfPoolLock.lock()
        
        ICWorkflow.wfPool.removeObject(identicalTo: self)
        let nextWorkflowToStart = ICWorkflow.wfPool.firstObject as? ICWorkflow
        
        if nextWorkflowToStart != nil {
            nextWorkflowToStart?.execute()
        }
        
        ICWorkflow.wfPoolLock.unlock()
    }

    open override var description: String {
        guard !_inProgress else { return "Cannot vizualize the workflow, if it's started" }
        return ICWFTextualVizualizer().descriptionOfWorkflow(self)
    }
}
