FPS = 60

def spawn_target(args)
  size = 64
  {
    x: rand(args.grid.w * 0.4) + args.grid.w * 0.6,
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: 'sprites/target.png',
  }
end

def fire_input?(args)
  args.inputs.keyboard.key_down.z ||
      args.inputs.keyboard.key_down.j ||
      args.inputs.keyboard.key_down.space ||
      args.inputs.controller_one.key_down.a
end

def handle_player_movement(args)
  if args.inputs.left
    args.state.player.x -= args.state.player.speed
  elsif args.inputs.right
    args.state.player.x += args.state.player.speed
  end

  if args.inputs.up
    args.state.player.y += args.state.player.speed
  elsif args.inputs.down
    args.state.player.y -= args.state.player.speed
  end

  #right boundary
  if args.state.player.x + args.state.player.w > args.grid.w
    args.state.player.x = args.grid.w - args.state.player.w
  end
  #left boundary
  if args.state.player.x < 0
    args.state.player.x = 0
  end

  #top boyndary
  if args.state.player.y + args.state.player.h > args.grid.h
    args.state.player.y = args.grid.h - args.state.player.h
  end

  #bottom boundary
  if args.state.player.y < 0
    args.state.player.y = 0
  end
end

HIGH_SCORE_FILE = "high-score.txt"
def game_over_tick(args)
  args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

  if !args.state.saved_high_score && args.state.score > args.state.high_score
    args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
    args.state.saved_high_score = true
  end
  
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
    text: "Score #{args.state.score}",
    size_enum: 4
  }
  labels << {
    x: 40,
    y: args.grid.h - 132,
    text: "Fire to restart",
    size_enum: 2,
  }
  if args.state.score > args.state.high_score
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "New high-score!",
      size_enum: 3,
    }
  else
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "Score to beat: #{args.state.high_score}",
      size_enum: 3,
    }
  end

  args.outputs.labels << labels
  if args.state.timer < -30 && fire_input?(args)
    $gtk.reset
  end
end  

def title_tick args
  if fire_input?(args)
    args.outputs.sounds << "sounds/game-over.wav"
    args.state.scene = "gameplay"
    return
  end
  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Target Practice",
    size_enum: 6,
  }
  labels << {
    x: 40,
    y: args.grid.h - 88,
    text: "Hit the targets!",
  }
  labels << {
    x: 40,
    y: args.grid.h - 120,
    text: "by Nathan",
  }
  labels << {
    x: 40,
    y: 120,
    text: "Arrows or WASD to move | Z or J to fire | gamepad works too",
  }
  labels << {
    x: 40,
    y: 80,
    text: "Fire to start",
    size_enum: 2,
  }
  args.outputs.labels << labels
end

def gameplay_tick(args)
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
  }
  args.state.player ||= {
    x: 120,
    y: 280,
    w: 100,
    h: 80,
    speed: 12,
    path: 'sprites/misc/dragon-0.png'
  }
  player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
  args.state.player.path = "sprites/misc/dragon-#{player_sprite_index}.png"
  args.state.fireballs ||= []
  args.state.targets ||= [
    spawn_target(args),
    spawn_target(args),
    spawn_target(args)
  ]
  args.state.score ||= 0
  args.state.timer ||= 30 * FPS

  args.state.timer -= 1

  if args.state.timer == 0
    args.audio[:music].paused = true
    args.outputs.sounds << "sounds/game-over.wav"
  end
  if args.state.timer < 0
    game_over_tick(args)
    return
  end

  handle_player_movement(args)

  if fire_input?(args)
    args.outputs.sounds << "sounds/fireball.wav"
    args.state.fireballs << {
      x: args.state.player.x + args.state.player.w - 12,
      y: args.state.player.y + 10,
      w: 32,
      h: 32,
      path: 'sprites/fireball.png',
    }
  end


  args.state.fireballs.each do |fireball|
    fireball.x += args.state.player.speed + 2
    if fireball.x > args.grid.w
      fireball.dead = true
      next
    end
    args.state.targets.each do |target|
      if args.geometry.intersect_rect?(target, fireball)
        args.outputs.sounds << "sounds/target.wav"
        target.dead = true
        fireball.dead = true
        args.state.score += 1
        args.state.targets << spawn_target(args)
      end
    end
  end

  args.state.targets.reject! {|t| t.dead}
  args.state.fireballs.reject! {|f| f.dead}
  args.outputs.sprites << [args.state.player, args.state.fireballs, args.state.targets]

  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Score: #{args.state.score}",
    size_enum: 4,
  }
  labels << {
    x: args.grid.w - 40,
    y: args.grid.h - 40,
    text: "Time Left: #{(args.state.timer / 60).round}",
    size_enum: 2,
    alignment_enum: 2,
  }
  args.outputs.labels << labels

end

def tick args
  if args.state.tick_count == 1
    args.audio[:music] = {input: "sounds/flight.ogg", looping: true}
  end

  args.state.scene ||= "title"
  
  send("#{args.state.scene}_tick", args)
end


$gtk.reset


# def tick args
#   args.state.logo_rect ||= { x: 576,
#                              y: 200,
#                              w: 128,
#                              h: 101 }

#   args.outputs.labels  << { x: 640,
#                             y: 600,
#                             text: 'Hello Everyone!',
#                             size_px: 30,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.labels  << { x: 640,
#                             y: 510,
#                             text: "Documentation is located under the ./docs directory. 150+ samples are located under the ./samples directory.",
#                             size_px: 20,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.labels  << { x: 640,
#                             y: 480,
#                             text: "You can also access these docs online at docs.dragonruby.org.",
#                             size_px: 20,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.labels  << { x: 640,
#                             y: 400,
#                             text: "The code that powers what you're seeing right now is located at ./mygame/app/main.rb.",
#                             size_px: 20,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.labels  << { x: 640,
#                             y: 380,
#                             text: "(you can change the code while the app is running and see the updates live)",
#                             size_px: 20,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.sprites << { x: args.state.logo_rect.x,
#                             y: args.state.logo_rect.y,
#                             w: args.state.logo_rect.w,
#                             h: args.state.logo_rect.h,
#                             path: 'dragonruby.png',
#                             angle: Kernel.tick_count }

#   args.outputs.labels  << { x: 640,
#                             y: 180,
#                             text: "(use arrow keys to move the logo around)",
#                             size_px: 20,
#                             anchor_x: 0.5,
#                             anchor_y: 0.5 }

#   args.outputs.labels  << { x: 640,
#                             y: 80,
#                             text: 'Please Join the Discord Server! https://discord.dragonruby.org',
#                             size_px: 30,
#                             anchor_x: 0.5 }

#   if args.inputs.keyboard.left
#     args.state.logo_rect.x -= 10
#   elsif args.inputs.keyboard.right
#     args.state.logo_rect.x += 10
#   end

#   if args.inputs.keyboard.down
#     args.state.logo_rect.y -= 10
#   elsif args.inputs.keyboard.up
#     args.state.logo_rect.y += 10
#   end

#   if args.state.logo_rect.x > 1280
#     args.state.logo_rect.x = 0
#   elsif args.state.logo_rect.x < 0
#     args.state.logo_rect.x = 1280
#   end

#   if args.state.logo_rect.y > 720
#     args.state.logo_rect.y = 0
#   elsif args.state.logo_rect.y < 0
#     args.state.logo_rect.y = 720
#   end
# end

