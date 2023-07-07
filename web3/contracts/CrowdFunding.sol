// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 goalAmount;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    /**
     * @notice Creates a new campaign with the given parameters and returns the index of the created campaign.
     * @param _owner The address of the campaign owner.
     * @param _title The title of the campaign.
     * @param _description The description of the campaign.
     * @param _target The target amount to be raised in the campaign.
     * @param _deadline The deadline for the campaign in UNIX timestamp format.
     * @param _image The image associated with the campaign.
     * @return The index of the created campaign in the storage.
     */
    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];
        require(
            campaign.deadline < block.timestamp,
            "Deadline must be in the future"
        );
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.goalAmount = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;
        campaign.amountCollected = 0;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    /**
     * @notice Allows a user to donate funds to a specific campaign identified by its ID.
     * @param _id The ID of the campaign to donate to.
     */
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool success, ) = payable(campaign.owner).call{value: amount}("");
        if (!success) {
            revert("Transfer failed");
        } else {
            campaign.amountCollected += amount;
        }
    }

    /**
     * @notice Retrieves the list of donators and their corresponding donation amounts for a specific campaign.
     * @param _id The ID of the campaign to retrieve donators from.
     * @return An array of addresses representing the donators and an array of uint256 representing the corresponding donation amounts.
     */

    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    /**
     * @notice Retrieves an array of all campaigns stored in the contract.
     * @return An array of Campaign structures representing all the campaigns.
     */

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory campaignsArray = new Campaign[](numberOfCampaigns);
        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage items = campaigns[i];
            campaignsArray[i] = items;
        }
        return campaignsArray;
    }
}
