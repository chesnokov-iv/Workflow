import UIKit

private class ICWFTextualVizualizerContext: NSObject {

    private var _blocksToDisplay: [ICWFTVDisplayBlock] = []
    fileprivate var blocksToDisplay: [ICWFTVDisplayBlock] { _blocksToDisplay }
    
    private var _displayedSteps: [ICWFStep] = []
    fileprivate var displayedSteps: [ICWFStep] { _displayedSteps }
    
    private var _nonTerminatedSteps: [ICWFStep] = []
    fileprivate var nonTerminatedSteps: [ICWFStep] { _nonTerminatedSteps }

    private var _cycleFromSteps: [ICWFStep] = []
    fileprivate var cycleFromSteps: [ICWFStep] { _cycleFromSteps }

    private var _cycleToSteps: [ICWFStep] = []
    fileprivate var cycleToSteps: [ICWFStep] { _cycleToSteps }

    fileprivate var maxWidth: Int = 0

    func addBlockToDisplay(_ newBlock: ICWFTVDisplayBlock) {
        _blocksToDisplay.append(newBlock)
        if newBlock.maxWidth > maxWidth {
            maxWidth = newBlock.maxWidth
        }
    }
    
    func addDisplayedStep(_ step: ICWFStep) {
        _displayedSteps.append(step)
    }

    func isDisplayedStep(_ step: ICWFStep) -> Bool {
        return (_displayedSteps.firstIndex(of: step) != nil)
    }

    func addNonTerminatedStep(_ step: ICWFStep) {
        _nonTerminatedSteps.append(step)
    }

    func addCycle(fromStep: ICWFStep, toStep: ICWFStep) {
        _cycleFromSteps.append(fromStep)
        _cycleToSteps.append(toStep)
    }

    var cyclesCount: Int { _cycleFromSteps.count }
}

open class ICWFTextualVizualizer: NSObject {

    func descriptionOfWorkflow(_ workflow: ICWorkflow) -> String {
        let context = ICWFTextualVizualizerContext()
        let beginBlock = ICWFTVUnDecoratedDisplayBlock()
        beginBlock.addString("\n\nBegin Workflow '\(String(describing: workflow.name))'" as NSString)
        context.addBlockToDisplay(beginBlock)
        context.addBlockToDisplay(ICWFTVSeparatorDisplayBlock())

        renderFlow(fromStep: workflow.firstStep, flowName: "", parentStep: nil, context: context)

        var stepIndex = 0
        while stepIndex < context.displayedSteps.count {
            let parentStep = context.displayedSteps[stepIndex]
            for chain in parentStep.chains {
                if chain == parentStep.nextChain || chain.firstStep == nil || chain.firstStep!.isKind(of: ICWFEndStep.self) {
                    continue
                }

                renderFlow(fromStep: chain.firstStep, flowName: chain.chainDescription! as String, parentStep: parentStep, context: context)
            }

            stepIndex += 1
        }

        let endBlock = ICWFTVUnDecoratedDisplayBlock()
        endBlock.addString("\nEnd Workflow '\(String(describing: workflow.name))'\n" as NSString)
        context.addBlockToDisplay(endBlock)

        context.maxWidth += 4

        var result = ""
        for blockToDisplay in context.blocksToDisplay {
            result.append(blockToDisplay.renderWithWidth(context.maxWidth))
        }

        let nonTerminatedStepsCount = context.nonTerminatedSteps.count
        result.append("The workflow has \(nonTerminatedStepsCount) non-terminated flow(s)\((nonTerminatedStepsCount > 0) ? ":\n" : "")")
        for nonTerminatedStep in context.nonTerminatedSteps {
            result.append("\(nonTerminatedStep.index). \(nonTerminatedStep.description)\n")
        }
        result.append("\n")

        let cyclesCount = context.cyclesCount
        result.append("The workflow has \(cyclesCount) cycled flow(s)\((cyclesCount > 0) ? ":\n" : "")")
        for cycleIndex in 0..<cyclesCount {
            let fromStep = context.cycleFromSteps[cycleIndex]
            let toStep = context.cycleToSteps[cycleIndex]
            result.append("from: ")
            result.append("{ \(fromStep.index). \(fromStep.description) }")
            result.append(" --> ")
            result.append("{ \(toStep.index). \(toStep.description) }")
            result.append("\n")
        }

        result.append("\n")
        return result
    }

    fileprivate func renderFlow(fromStep firstStep: ICWFStep?, flowName: String, parentStep: ICWFStep?, context: ICWFTextualVizualizerContext) {
        let beginBlock = ICWFTVUnDecoratedDisplayBlock()
        let flowContext = (parentStep != nil) ? "( \(parentStep!.index). \(parentStep!.description) )" : ""
        if flowName.count > 0 {

            beginBlock.addString("\nBegin a flow '\(flowName)'" as NSString)
            if flowContext.count > 0 {
                beginBlock.addString(flowContext as NSString)
            }

        } else {
            beginBlock.addString("\nBegin a main flow" as NSString)
        }

        context.addBlockToDisplay(beginBlock)

        var currentStep: ICWFStep? = firstStep
        var prevStep: ICWFStep? = parentStep

        while currentStep != nil {
            if context.isDisplayedStep(currentStep!) {
                let newBlock = ICWFTVDecoratedDisplayBlock()
                newBlock.addString("Goto step: \(currentStep!.index). ( \(currentStep!.description) )" as NSString)
                context.addBlockToDisplay(newBlock)
                if prevStep != nil {
                    context.addCycle(fromStep: prevStep!, toStep: currentStep!)
                }
                break
            }

            let newBlock = ICWFTVDecoratedDisplayBlock()
            newBlock.addString("\(currentStep!.index). \(currentStep!.description)" as NSString)
            newBlock.addString("( \(NSStringFromClass(currentStep!.classForCoder)) )" as NSString)
            let chains = currentStep!.chains
            if chains.count > 1 {
                newBlock.addString("")
            }
            for chain in chains where chain != currentStep!.nextChain {
                var chainLinkDescription = "shown in the specific section"
                if chain.firstStep == nil {
                    chainLinkDescription = "??__UNASSIGNED__??"
                    context.addNonTerminatedStep(currentStep!)
                }
                newBlock.addString("\(String(describing: chain.chainDescription)): \(chainLinkDescription)" as NSString)
            }
            context.addBlockToDisplay(newBlock)
            context.addDisplayedStep(currentStep!)

            prevStep = currentStep
            currentStep = currentStep!.nextChain.firstStep

            if currentStep != nil && currentStep!.isKind(of: ICWFEndStep.self) {
                break
            }

            let arrowBlock = ICWFTVUnDecoratedDisplayBlock()
            arrowBlock.addString("|")
            arrowBlock.addString("V")
            context.addBlockToDisplay(arrowBlock)

            if currentStep == nil {
                let endBlock = ICWFTVDecoratedDisplayBlock()
                endBlock.addString("XXX_UNTERMINATED_FLOW_XXX")
                context.addBlockToDisplay(endBlock)
                context.addNonTerminatedStep(prevStep!)
                break
            }
        }

        let endBlock = ICWFTVUnDecoratedDisplayBlock()
        if flowName.count > 0 {
            endBlock.addString("End of the flow '\(flowName)'" as NSString)
            if flowContext.count > 0 {
                endBlock.addString(flowContext as NSString)
            }
        } else {
            endBlock.addString("End of the main flow" as NSString)
        }
        context.addBlockToDisplay(endBlock)
        context.addBlockToDisplay(ICWFTVSeparatorDisplayBlock())
    }
}
