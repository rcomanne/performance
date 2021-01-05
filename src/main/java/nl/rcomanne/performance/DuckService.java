package nl.rcomanne.performance;

import java.util.List;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class DuckService {

    private final DuckRepository repository;

    public Duck findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new IllegalArgumentException("no duck found with id " + id));
    }

    public List<Duck> findAll() {
        return repository.findAll();
    }

    public Duck saveDuck(Duck duck) {
        return repository.save(duck);
    }

    public List<Duck> saveDucks(List<Duck> ducks) {
        return repository.saveAll(ducks);
    }

    public void deleteDuck(Long id) {
        repository.deleteById(id);
    }

    public void deleteAllDucks() {
        repository.deleteAll();
    }
}
