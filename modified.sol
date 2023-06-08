function submitSDPrice(SDPriceData calldata _sdPriceData) external override trustedNodeOnly checkMinTrustedNodes {
    if (_sdPriceData.reportingBlockNumber >= block.number) {
        revert ReportingFutureBlockData();
    }
    if (_sdPriceData.reportingBlockNumber % updateFrequencyMap[SD_PRICE_UF] > 0) {
        revert InvalidReportingBlock();
    }
    if (_sdPriceData.reportingBlockNumber <= lastReportedSDPriceData.reportingBlockNumber) {
        revert ReportingPreviousCycleData();
    }

    // Get submission keys
    bytes32 nodeSubmissionKey = keccak256(abi.encode(msg.sender, _sdPriceData.reportingBlockNumber));
    bytes32 submissionCountKey = keccak256(abi.encode(_sdPriceData.reportingBlockNumber));
    uint8 submissionCount = attestSubmission(nodeSubmissionKey, submissionCountKey);
    insertSDPrice(_sdPriceData.sdPriceInETH);

    // Check if the submission is accurate
    bool isAccurateSubmission = isPriceAccurate(_sdPriceData.sdPriceInETH);

    // Apply penalties or incentives based on accuracy
    if (isAccurateSubmission) {
        // Accurate submission, provide incentives
        uint256 incentiveAmount = calculateIncentiveAmount();
        // Transfer incentiveAmount tokens to the submitter
        // (Assuming there's a function to transfer tokens, replace with the appropriate code)
        transferTokens(msg.sender, incentiveAmount);
    } else {
        // Inaccurate submission, impose penalty
        uint256 penaltyAmount = calculatePenaltyAmount();
        // Transfer penaltyAmount tokens from the submitter
        // (Assuming there's a function to transfer tokens, replace with the appropriate code)
        transferTokensFrom(msg.sender, penaltyAmount);
    }

    // Emit SD Price submitted event
    emit SDPriceSubmitted(msg.sender, _sdPriceData.sdPriceInETH, _sdPriceData.reportingBlockNumber, block.number);

    // price can be derived once more than 66% percent oracles have submitted price
    if ((submissionCount == (2 * trustedNodesCount) / 3 + 1)) {
        lastReportedSDPriceData = _sdPriceData;
        lastReportedSDPriceData.sdPriceInETH = getMedianValue(sdPrices);
        delete sdPrices;

        // Emit SD Price updated event
        emit SDPriceUpdated(_sdPriceData.sdPriceInETH, _sdPriceData.reportingBlockNumber, block.number);
    }
}
