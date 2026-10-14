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
          args.state.current_player = args.state.current_player == "X" ? "O" : "X"
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
    text: "Click a square to make a move",
  }
  args.outputs.labels << labels
end

def gameplay_tick(args)
  board_init(args)
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
    if  piece == "X"
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
    elsif piece == "O"
      args.outputs.sprites << {
        x: cell_x + padding,
        y: cell_y + padding,
        w: size,
        h: size,
        path: 'sprites/circle.png',
        r: 255,
        g: 255,
        b: 0,
      }
    end
  end
  handle_player_turn(args)
  if args.state.game_over
    args.state.scene ||= "game_over"
  end
end

def tick args
  if args.state.tick_count == 1
  end  
  args.state.scene ||= "title"
  send("#{args.state.scene}_tick", args)
end

def board_init args
  args.state.tttboard ||= [nil, nil, nil, nil, nil, nil, nil, nil, nil]
  args.state.current_player ||= "X"
  args.state.game_over ||= false
  args.state.move_count ||= 0
end

def is_winner?(args)
end

def ex_spirte args
end

def oh_sprite args
end


def game_over_tick(args)
  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Game Over!",
    size_enum: 10,
  }
  labels << {
    x: 40,
    y: args.grid.h - 90,
    text: "#{args.state.winner} wins",
    size_enum: 4
  }
  labels << {
    x: 40,
    y: args.grid.h - 132,
    text: "click to restart",
    size_enum: 2,
  }
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


