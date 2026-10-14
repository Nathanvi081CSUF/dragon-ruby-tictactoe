FPS = 60

def user_input?(args)
  args.inputs.mouse.click
end

def handle_player_turn(args)  
  if args.state.game_over
    return
  end
  if user_input?(args)
    x_pos = args.inputs.mouse.click.x
    y_pos = args.inputs.mouse.click.y
    margin_x = 370
    margin_y = 90
    cell_size = 180
    col = ((x_pos - margin_x) / cell_size).floor
    row = ((y_pos - margin_y) / cell_size).floor
    if col >= 0 && col < 3 && row >= 0 && row < 3
      clicked_space = col + (row * 3)
      if args.state.tttboard[clicked_space].nil?
        args.state.tttboard[clicked_space] = args.state.current_player
        args.state.move_count += 1
        is_winner?(args)
        unless args.state.game_over
          args.state.current_player = args.state.current_player == "1" ? "2" : "1"
        end
      end
    end
  end
end

def title_tick args
  if user_input?(args)
    args.state.scene = "gameplay"
    return
  end
  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Tic Tac Toe",
    size_enum: 6,
  }
  labels << {
    x: 40,
    y: args.grid.h - 120,
    text: "by Nathan",
  }
  labels << {
    x: 40,
    y: 120,
    text: "Rules: Click a square to make a move",
  }
  labels << {
    x: 40,
    y: 90,
    text: "Click anywhere to begin",
  }
  labels << {
    x: 40,
    y: 400,
    text: "Player 1: X",
  }
  labels << {
    x: 40,
    y: 360,
    text: "Player 2: O",
  }
  args.outputs.labels << labels
end

def gameplay_tick(args)
  board_init(args)
  labels = []
  labels << {
    x: 40
    y: args.grid.h - 120,
    text: player
  }
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 123,
    g: 221,
    b: 236,
  }
  thickness = 10
  board_size = 540
  args.outputs.solids << {
    x: (370 + 180) - (thickness / 2),
    y: 90,
    w: thickness,
    h: board_size,
    r: 255, g: 255, b: 255,
  }
  args.outputs.solids << {
    x: (370 + 360) - (thickness / 2),
    y: 90,
    w: thickness,
    h: board_size,
    r: 255, g: 255, b: 255,
  }
  args.outputs.solids << {
    x: 370,
    y: (90 + 180) - (thickness / 2),
    w: board_size,
    h: thickness,
    r: 255, g: 255, b: 255,
  }
  args.outputs.solids << {
    x: 370,
    y: (90 + 360) - (thickness / 2),
    w: board_size,
    h: thickness,
    r: 255, g: 255, b: 255,
  }
  args.state.tttboard.each_with_index do |piece, index|
    next if piece.nil?
    col = index % 3
    row = (index / 3).floor
    cell_x = 370 + (col * 180)
    cell_y = 90 + (row * 180)
    padding = 20
    size = 140
    if  piece == "1"
      args.outputs.lines << {
        x: cell_x + padding,
        y: cell_y + padding,
        x2: cell_x + padding + size,
        y2: cell_y + padding + size,
        r: 50,
        g: 205,
        b: 50,
      }
      args.outputs.lines << {
        x: cell_x + padding,
        y: cell_y + padding + size,
        x2: cell_x + padding + size,
        y2: cell_y + padding,
        r: 50,
        g: 205,
        b: 50,
      }
    elsif piece == "2"
      args.outputs.sprites << {
        x: cell_x + padding,
        y: cell_y + padding,
        w: size,
        h: size,
        path: 'sprites/oh_sprite.png',
      }
    end
  end
  handle_player_turn(args)
  if args.state.game_over
    args.state.game_ends ||= args.state.tick_count
    if args.state.tick_count >= args.state.game_ends + 35
      args.state.scene = "game_over"
    end
  end
end

def tick args
  if args.state.tick_count == 1
  end  
  args.state.scene ||= "title"
  send("#{args.state.scene}_tick", args)
end

def board_init args
  args.state.tttboard ||= [
    nil, nil, nil,
    nil, nil, nil,
    nil, nil, nil]
  args.state.current_player ||= "1"
  args.state.game_over ||= false
  args.state.move_count ||= 0
end

def is_winner?(args)
  if args.state.move_count < 5
    return
  end
  winning_combo = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
  winning_combo.each do |line|
    pos1 = args.state.tttboard[line[0]]
    pos2 = args.state.tttboard[line[1]]
    pos3 = args.state.tttboard[line[2]]
    if !pos1.nil? && pos1 == pos2 && pos2 == pos3
      args.state.game_over = true
      args.state.winner = pos1
      return
    end
  end
  if args.state.move_count >= 9
    args.state.game_over = true
    args.state.winner = "Draw"
  end
end


def game_over_tick(args)
  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Game Over!",
    size_enum: 10,
  }
  if args.state.winner == "1"
    labels << {
      x: 40,
      y: args.grid.h - 90,
      text: "Player 1 wins",
      size_enum: 4
    }
  elsif args.state.winner == "2"
    labels << {
      x: 40,
      y: args.grid.h - 90,
      text: "Player 2 wins",
      size_enum: 4
    }
  elsif args.state.winner == "Draw"
    labels << {
      x: 40,
      y: args.grid.h - 90,
      text: "Draw",
      size_enum: 4
    }
  end
  labels << {
    x: 40,
    y: args.grid.h - 132,
    text: "click to restart",
    size_enum: 2,
  }
  args.outputs.labels << labels
  if user_input?(args)
    $gtk.reset
  end
end  


$gtk.reset


# def spawn_target(args)
#   size = 64
#   {
#     x: rand(args.grid.w * 0.4) + args.grid.w * 0.6,
#     y: rand(args.grid.h - size * 2) + size,
#     w: size,
#     h: size,
#     path: 'sprites/target.png',
#   }
# end



# HIGH_SCORE_FILE = "high-score.txt"
#def game_over_tick(args)
# args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

#   if !args.state.saved_high_score && args.state.score > args.state.high_score
#     args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
#     args.state.saved_high_score = true
#   end
  
#   labels = []
#   labels << {
#     x: 40,
#     y: args.grid.h - 40,
#     text: "Game Over!",
#     size_enum: 10,
#   }
#   labels << {
#     x: 40,
#     y: args.grid.h - 90,
#     text: "Score #{args.state.score}",
#     size_enum: 4
#   }
#   labels << {
#     x: 40,
#     y: args.grid.h - 132,
#     text: "Fire to restart",
#     size_enum: 2,
#   }
#   if args.state.score > args.state.high_score
#     labels << {
#       x: 260,
#       y: args.grid.h - 90,
#       text: "New high-score!",
#       size_enum: 3,
#     }
#   else
#     labels << {
#       x: 260,
#       y: args.grid.h - 90,
#       text: "Score to beat: #{args.state.high_score}",
#       size_enum: 3,
#     }
#   end

#   args.outputs.labels << labels
#   if args.state.timer < -30 && fire_input?(args)
#     $gtk.reset
#   end
# end  


