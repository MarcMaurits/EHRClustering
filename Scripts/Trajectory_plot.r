ggplot(tst, aes(x = 1:10, y = Probability, size = Proportion, colour = Proportion, label = Phenotype)) +
	geom_point() +
	geom_line(size = 0.5,
			  colour = "black") +
	geom_label_repel(size = 3,
					 colour = "black") +
	theme_classic() +
	theme(axis.text.x = element_blank(),
		  axis.ticks.x = element_blank()) +
	labs(title = "Trajectory plot",
		 x = "Order (First -> Last)",
		 y = "Transition Probability")