package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.ItemRow;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** The questions, read from the active version of the inventory. */
@ApplicationScoped
public class ItemPool {

  /// 1..points is what an answer may be. The scale is the instrument, not
  /// copy: changing it changes every score ever recorded.
  public static final int points = 5;

  private final ContentStore content;

  ItemPool(ContentStore content) {
    this.content = content;
  }

  public List<Item> all() {
    return List.copyOf(byId().values());
  }

  public Item byId(String id) {
    return byId().get(id);
  }

  /** Which generation of the inventory produced a result taken now. */
  public int version() {
    return content.activeItemVersion();
  }

  public int likertPoints() {
    return points;
  }

  private Map<String, Item> byId() {
    Map<String, Item> items = new LinkedHashMap<>();
    for (ItemRow row : content.activeItems()) {
      items.put(
          row.id(),
          new Item(row.id(), Dimension.of(row.dimension()), row.reverse(), row.text()));
    }
    return items;
  }
}
