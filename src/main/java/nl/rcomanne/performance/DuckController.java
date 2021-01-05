package nl.rcomanne.performance;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/ducks")
@RequiredArgsConstructor
public class DuckController {

    private final DuckService duckService;
    private final Random r = new Random();

    @GetMapping
    public ResponseEntity<List<Duck>> getDucks() {
        log.info("getting all ducks");
        return ResponseEntity.ok(duckService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Duck> findById(@PathVariable("id") Long id) {
        log.info("getting duck with id " + id);
        return ResponseEntity.ok(duckService.findById(id));
    }

    @PostMapping
    public ResponseEntity<List<Duck>> createDucks() {
        final List<String> names = List.of("Arie", "Donald", "Dagobert", "Edwin", "Frank", "Guus", "Katrien", "Kwik", "Kwek", "Kwak", "Niels", "Onno", "Ralph", "Sietse");
        final List<String> colours = List.of("Black", "Brown", "Green", "Grey");

        log.info("creating ducks");
        final List<Duck> createdDucks = new ArrayList<>();
        for (int i = 0; i < 100; i++) {
            Duck duck = Duck.builder()
                .name(names.get(r.nextInt(names.size())))
                .age(r.nextInt(100))
                .colour(colours.get(r.nextInt(colours.size())))
                .build();
            createdDucks.add(duckService.saveDuck(duck));
        }
        return ResponseEntity.ok(createdDucks);
    }

    @DeleteMapping
    public void deleteAllDucks() {
        log.info("deleting all ducks");
        duckService.deleteAllDucks();
    }

    @DeleteMapping("/{id}")
    public void deleteDuck(@PathVariable("id") Long id) {
        log.info("deleting duck with id " + id);
        duckService.deleteDuck(id);
    }
}
