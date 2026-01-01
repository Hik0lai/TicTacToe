import { useState, useCallback, useRef } from "react";
import Player from "./components/Player.jsx"
import GameBoard from "./components/GameBoard.jsx"

function App() {
  const [activePlayer, setActivePlayer] = useState('X');
  const [gameBoard, setGameBoard] = useState([
    [null, null, null],
    [null, null, null],
    [null, null, null]
  ]);
  const [gameWon, setGameWon] = useState(null); // 'X', 'O', or null
  const [isGameActive, setIsGameActive] = useState(true);
  
  // Win counters
  const [player1Wins, setPlayer1Wins] = useState(0);
  const [player2Wins, setPlayer2Wins] = useState(0);
  
  // Ref to track if win has been processed to prevent multiple increments
  const winProcessedRef = useRef(false);

  function handleSelectSquare(newBoard) {
    setGameBoard(newBoard);
    if (!gameWon) {
      setActivePlayer((currActivePlayer) => currActivePlayer === 'X' ? 'O' : 'X');
    }
  }

  const handleGameWin = useCallback((winner) => {
    // Only process win once
    if (winProcessedRef.current) {
      return;
    }
    winProcessedRef.current = true;
    setGameWon(winner);
    setIsGameActive(false);
    // Increment win counter
    if (winner === 'X') {
      setPlayer1Wins(prev => prev + 1);
    } else {
      setPlayer2Wins(prev => prev + 1);
    }
  }, []);

  function handleResetGame(e) {
    e?.preventDefault?.();
    e?.stopPropagation?.();
    // Reset win processed flag
    winProcessedRef.current = false;
    setGameBoard([
      [null, null, null],
      [null, null, null],
      [null, null, null]
    ]);
    setGameWon(null);
    setIsGameActive(true);
    setActivePlayer('X');
  }

  function handleResetCounter(playerSymbol) {
    if (playerSymbol === 'X') {
      setPlayer1Wins(0);
    } else {
      setPlayer2Wins(0);
    }
  }

  return (
    <main>
    <div id="game-container">
      <ol id="players" className="highlight-player">
        <Player 
          initialName="PPPlayer 1" 
          symbol="X" 
          isActive={activePlayer==='X' && !gameWon}
          wins={player1Wins}
          onResetCounter={() => handleResetCounter('X')}
        />
        <Player 
          initialName="PPPlayer 2" 
          symbol="O" 
          isActive={activePlayer==='O' && !gameWon}
          wins={player2Wins}
          onResetCounter={() => handleResetCounter('O')}
        />
      </ol>
      {gameWon && (
        <div id="win-message">
          <h2>🎉 Player {gameWon === 'X' ? '1' : '2'} Wins! 🎉</h2>
          <button onClick={handleResetGame}>Play Again</button>
        </div>
      )}
      <GameBoard 
        onSelectSquare={handleSelectSquare}
        activePlayerSymbol={activePlayer}
        gameBoard={gameBoard}
        onGameWin={handleGameWin}
        isGameActive={isGameActive}
      />
    </div>
      LOG
    </main>
  )
}

export default App
