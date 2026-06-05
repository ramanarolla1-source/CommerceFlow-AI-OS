// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ComplianceAudit
 * @dev Anchors business transaction metadata to the blockchain for SAT/Regulatory auditability.
 */
contract ComplianceAudit {
    
    struct AuditRecord {
        string invoiceRef;
        string whatsappThreadId;
        uint256 timestamp;
        uint256 amount;
        string ipfsHash; // Link to the full detailed audit report
        address operator;
    }

    mapping(string => AuditRecord) public auditTrail;
    event AuditLogCreated(string invoiceRef, string ipfsHash);

    // Logs the compliance record upon settlement
    function anchorAuditRecord(
        string memory _invoiceRef,
        string memory _whatsappThreadId,
        uint256 _amount,
        string memory _ipfsHash
    ) public {
        auditTrail[_invoiceRef] = AuditRecord({
            invoiceRef: _invoiceRef,
            whatsappThreadId: _whatsappThreadId,
            timestamp: block.timestamp,
            amount: _amount,
            ipfsHash: _ipfsHash,
            operator: msg.sender
        });

        emit AuditLogCreated(_invoiceRef, _ipfsHash);
    }

    function verifyRecord(string memory _invoiceRef) public view returns (AuditRecord memory) {
        return auditTrail[_invoiceRef];
    }
}
