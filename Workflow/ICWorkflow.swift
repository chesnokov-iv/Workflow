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
        print("The workflow '\(String(describing: self.name))' (\(NSStringFromClass(self.classForCoder))) is deallocating")
        #endif
    }

    public func firstStep(is firstStepObj: ICWFStep?) -> ICWFStep? {
        guard _firstStepObj == nil else {
            return nextStep(firstStepObj)
        }

        firstStepObj?.owner = self
        if firstStepObj != nil {
            _steps.append(firstStepObj!)
        }
        _firstStepObj = firstStepObj
        _firstStepObj?.index = _steps.count
        _lastStepObj = _firstStepObj

        return _firstStepObj
    }

    public func nextStep(_ nextStepObj: ICWFStep?) -> ICWFStep? {
        return nextStep(for: _lastStepObj?.nextChain, is: nextStepObj)
    }

    public func nextStep(for targetChain: ICWFChain?, is nextStepObj: ICWFStep?) -> ICWFStep? {
        guard targetChain?.firstStep == nil, let nextStep = nextStepObj else {
            return nil
        }

        nextStep.owner = self
        _steps.append(nextStep)
        targetChain!.firstStep = nextStep

        if nextStep.index == 0 {
            nextStep.index = _steps.count
        }

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
    }

    open override var description: String {
        guard !_inProgress else { return "Cannot vizualize the workflow, if it's started" }
        return ICWFTextualVizualizer().descriptionOfWorkflow(self)
    }
}
