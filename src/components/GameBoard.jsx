import { useEffect, useRef } from 'react';

export default function GameBoard({onSelectSquare, activePlayerSymbol, gameBoard, onGameWin, isGameActive}) {
    const hasCheckedWinRef = useRef(false);
    
    function checkWinner(board) {
        // Check rows
        for (let row = 0; row < 3; row++) {
            if (board[row][0] && 
                board[row][0] === board[row][1] && 
                board[row][1] === board[row][2]) {
                return board[row][0];
            }
        }
        
        // Check columns
        for (let col = 0; col < 3; col++) {
            if (board[0][col] && 
                board[0][col] === board[1][col] && 
                board[1][col] === board[2][col]) {
                return board[0][col];
            }
        }
        
        // Check diagonal (top-left to bottom-right)
        if (board[0][0] && 
            board[0][0] === board[1][1] && 
            board[1][1] === board[2][2]) {
            return board[0][0];
        }
        
        // Check diagonal (top-right to bottom-left)
        if (board[0][2] && 
            board[0][2] === board[1][1] && 
            board[1][1] === board[2][0]) {
            return board[0][2];
        }
        
        return null;
    }

    // Check for winner after each board update
    useEffect(() => {
        if (!isGameActive || hasCheckedWinRef.current) {
            return; // Don't check if game is already won/inactive or already checked
        }
        const winner = checkWinner(gameBoard);
        if (winner && onGameWin) {
            hasCheckedWinRef.current = true;
            onGameWin(winner);
        }
    }, [gameBoard, isGameActive, onGameWin]);

    // Reset check flag when game is reset
    useEffect(() => {
        if (isGameActive) {
            hasCheckedWinRef.current = false;
        }
    }, [isGameActive]);

    function handleClick(rowIndex, collIndex) {
        // Don't allow moves if game is won or square is already filled
        if (!isGameActive || gameBoard[rowIndex][collIndex]) {
            return;
        }

        const updatedBoard = gameBoard.map(row => [...row]);
        updatedBoard[rowIndex][collIndex] = activePlayerSymbol;
        
        onSelectSquare(updatedBoard);
    }

    return (
    <ol id="game-board">
        {gameBoard.map((row, rowIndex) => 
        <li key={rowIndex}>
            <ol>
                {row.map((playerSymbol, collIndex) => 
                <li key={collIndex}>
                    <button 
                        onClick={()=>handleClick(rowIndex, collIndex)}
                        disabled={!isGameActive || playerSymbol !== null}
                    >
                        {playerSymbol}
                    </button>
                </li>)}
            </ol>
        </li>)}
    </ol>
    );
}