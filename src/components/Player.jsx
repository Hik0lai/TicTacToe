import { useState } from "react";
export default function Player({initialName, symbol, isActive, wins, onResetCounter}) {
    const [playerName, setPlayerName] = useState(initialName);
    const [isEditing , setIsEditing] = useState(false);
    
    function handleEditClick() {
        console.log("Edit button clicked");
        setIsEditing((editing) => !editing);
    }
    
    let editablePlayerName = <span className="player-name">{playerName}</span>;
    if(isEditing) 
        editablePlayerName = <input type="text" required defaultValue={playerName} onChange={handleNameChange}></input>

    function handleNameChange(event) {
        setPlayerName(event.target.value);
    }

    function handleResetCounterClick() {
        if (onResetCounter) {
            onResetCounter();
        }
    }

    return (
        <li className={isActive ? 'active' : undefined}>
            <div className="player-container">
                <span className="player">
                    {editablePlayerName}
                    <span className="player-symbol">{symbol}</span>
                </span>
                <div className="player-stats">
                    <span className="player-wins">
                        🏆 Wins: {wins || 0}
                    </span>
                    <button className="reset-counter-btn" onClick={handleResetCounterClick}>Reset</button>
                    <button className="edit-btn" onClick={handleEditClick}>{isEditing?'Save':'Edit'}</button>
                </div>
            </div>
        </li>
    );
}