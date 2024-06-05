/* The Demo Football Database - used in class as part of Lessons F and G */

IF exists(select * from sys.objects where name='demo_football_players')
	DROP TABLE [dbo].[demo_football_players]
GO
IF exists(select * from sys.objects where name='demo_football_teams')
	DROP TABLE [dbo].[demo_football_teams]
GO

CREATE TABLE [dbo].[demo_football_players](
	[player_name] [varchar](50) NOT NULL,
	[player_team] [varchar](50) NULL,
	[total_yards] [int] NULL,
	[touchdowns] [int] NULL,
 CONSTRAINT [pk_demo_football_players_player_name] PRIMARY KEY CLUSTERED 
(
	[player_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[demo_football_teams](
	[team_name] [varchar](50) NOT NULL,
 CONSTRAINT [pk_demo_football_teams_team_name] PRIMARY KEY CLUSTERED 
(
	[team_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[demo_football_players]  WITH CHECK ADD  CONSTRAINT [fk_demo_football_players_player_team] FOREIGN KEY([player_team])
REFERENCES [dbo].[demo_football_teams] ([team_name])
GO

ALTER TABLE [dbo].[demo_football_players] CHECK CONSTRAINT [fk_demo_football_players_player_team]
GO

