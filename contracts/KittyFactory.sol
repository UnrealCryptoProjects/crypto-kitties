pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./KittyContract.sol";

contract KittyFactory is Ownable, KittyContract {
    using SafeMath32 for uint32;

    uint256 public constant CREATION_LIMIT_GEN0 = 10;
    uint256 internal _gen0Counter;

    event Birth(
        address owner,
        uint256 kittyId,
        uint256 mumId,
        uint256 dadId,
        uint256 genes
    );

    function kittiesOf(address _owner) public view returns (uint256[] memory) {
        // get the number of kittes owned by _owner
        uint256 ownerCount = ownerKittyCount[_owner];
        if (ownerCount == 0) {
            return new uint256[](0);
        }

        // iterate through each kittyId until we find all the kitties
        // owned by _owner
        uint256[] memory ids = new uint256[](ownerCount);
        uint256 i = 1;
        uint256 count = 0;
        while (count < ownerCount || i < kitties.length) {
            if (kittyToOwner[i] == _owner) {
                ids[count] = i;
                count = count.add(1);
            }
            i = i.add(1);
        }

        return ids;
    }

    function getGen0Count() public view returns (uint256) {
        return _gen0Counter;
    }

    function createKittyGen0(uint256 _genes)
        public
        onlyOwner
        returns (uint256)
    {
        require(_gen0Counter < CREATION_LIMIT_GEN0, "gen0 limit exceeded");

        _gen0Counter = _gen0Counter.add(1);
        return _createKitty(0, 0, 0, _genes, msg.sender);
    }

    function _createKitty(
        uint256 _mumId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint256) {
        Kitty memory kitty = Kitty({
            genes: _genes,
            birthTime: uint64(now),
            mumId: uint32(_mumId),
            dadId: uint32(_dadId),
            generation: uint16(_generation)
        });

        uint256 newKittenId = kitties.push(kitty) - 1;
        emit Birth(_owner, newKittenId, _mumId, _dadId, _genes);

        _transfer(address(0), _owner, newKittenId);

        return newKittenId;
    }
}
